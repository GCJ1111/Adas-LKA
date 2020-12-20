//
//  GameVC+AddElemets.swift
//  SceneKitVehicle
//
//  Created by 龚晨杰 on 2020/11/28.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

extension GameViewController
{
    
    func addRoadToScene(_ scene: SCNScene) {
        // add Road
    
        guard let myScene = SCNScene(named: "art.scnassets/Lane-x3.scn")
        else { fatalError("Unable to load scene file.") }
        
        
        // 获取 scnce 中的 Node ， 得到一个 【SCNNode?】
        let lane_tmplt = myScene.rootNode.childNode(withName: "lane-1", recursively: false)
        
        
        //        lane_tmplt?.scale = SCNVector3(1.5, 1.5, 1.0)
        
        for i in stride( from : -2 , through : 20 ,  by : 1.0){
            let poxZ:Float = Float(12.0 * i);
            
            if let lane_x1 = lane_tmplt?.clone(){
                // 解决 渲染重影问题 ，设置 y != 0 即可。
                // 不能在 editor中设置，因为最终起作用的是在这里。
                lane_x1.position = SCNVector3Make(0.0 , 0.001,  poxZ);
                
//                GLog("Turn-\(i) :\(lane_x1.position.z)");
                
                scene.rootNode.addChildNode(lane_x1)
                
            }
            
        }
    }
    
    
    func addCarpetToScene(_ scene: SCNScene) {
        // add carpet
        let rug = SCNNode()
        rug.position = SCNVector3Make(0, 0.01, 0)
        rug.rotation = SCNVector4Make(1, 0, 0, .pi/2)
        let path = UIBezierPath(roundedRect: CGRect(x: -50, y: -30, width: 100, height: 50), cornerRadius: 2.5)
        path.flatness = 0.1
        rug.geometry = SCNShape(path: path, extrusionDepth: 0.05)
        rug.geometry!.firstMaterial!.locksAmbientWithDiffuse = true
        rug.geometry!.firstMaterial!.diffuse.contents = "carpet.jpg"
        scene.rootNode.addChildNode(rug)
    }
    
    func addCartoonBookToScene(_ scene: SCNScene) {
        
        // add cartoon book
        let block = SCNNode()
        block.position = SCNVector3Make(20, 10, -16)
        block.rotation = SCNVector4Make(0, 1, 0, -Float.pi/4)
        block.geometry = SCNBox(width: 22, height: 0.2, length: 34, chamferRadius: 0)
        let frontMat = SCNMaterial()
        frontMat.locksAmbientWithDiffuse = true
        frontMat.diffuse.contents = "book_front.jpg"
        frontMat.diffuse.mipFilter = .linear
        let backMat = SCNMaterial()
        backMat.locksAmbientWithDiffuse = true
        backMat.diffuse.contents = "book_back.jpg"
        backMat.diffuse.mipFilter = .linear
        block.geometry!.materials = [frontMat, backMat]
        block.physicsBody = SCNPhysicsBody.dynamic()
        scene.rootNode.addChildNode(block)
    }
    
    func addWallToScene(_ scene: SCNScene) {
        
        // add walls
        let wall = SCNNode(geometry: SCNBox(width: 400, height: 100, length: 4, chamferRadius: 0))
        wall.geometry!.firstMaterial!.diffuse.contents = "wall.jpg"
        wall.geometry!.firstMaterial!.diffuse.contentsTransform = SCNMatrix4Mult(SCNMatrix4MakeScale(24, 2, 1), SCNMatrix4MakeTranslation(0, 1, 0))
        wall.geometry!.firstMaterial!.diffuse.wrapS = .repeat
        wall.geometry!.firstMaterial!.diffuse.wrapT = .mirror
        wall.geometry!.firstMaterial!.isDoubleSided = false
        wall.castsShadow = false
        wall.geometry!.firstMaterial!.locksAmbientWithDiffuse = true
        
        wall.position = SCNVector3Make(0, 50, -92)
        wall.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(wall)
        
        let wallC = wall.clone()
        wallC.position = SCNVector3Make(-202, 50, 0)
        wallC.rotation = SCNVector4Make(0, 1, 0, .pi/2)
        scene.rootNode.addChildNode(wallC)
        
        let wallD = wall.clone()
        wallD.position = SCNVector3Make(202, 50, 0)
        wallD.rotation = SCNVector4Make(0, 1, 0, -Float.pi/2)
        scene.rootNode.addChildNode(wallD)
        
        let backWall = SCNNode(geometry: SCNPlane(width: 400, height: 100))
        backWall.geometry!.firstMaterial = wall.geometry!.firstMaterial
        backWall.position = SCNVector3Make(0, 50, 200)
        backWall.rotation = SCNVector4Make(0, 1, 0, .pi)
        backWall.castsShadow = false
        backWall.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(backWall)
        
        // add ceil
        let ceilNode = SCNNode(geometry: SCNPlane(width: 400, height: 400))
        ceilNode.position = SCNVector3Make(0, 100, 0)
        ceilNode.rotation = SCNVector4Make(1, 0, 0, .pi/2)
        ceilNode.geometry!.firstMaterial!.isDoubleSided = false
        ceilNode.castsShadow = false
        ceilNode.geometry!.firstMaterial!.locksAmbientWithDiffuse = true
        scene.rootNode.addChildNode(ceilNode)
        
    }
    
    func addTrainToScene(_ scene: SCNScene, atPosition pos: SCNVector3) {
        let trainScene = SCNScene(named: "train_flat")!
        
        //physicalize the train with simple boxes
        for node in trainScene.rootNode.childNodes {
            //let node = obj as! SCNNode
            if node.geometry != nil {
                node.position = SCNVector3Make(node.position.x + pos.x, node.position.y + pos.y, node.position.z + pos.z)
                
                let (min, max) = node.boundingBox
                
                let body = SCNPhysicsBody.dynamic()
                let boxShape = SCNBox(width:CGFloat(max.x - min.x), height:CGFloat(max.y - min.y), length:CGFloat(max.z - min.z), chamferRadius:0.0)
                body.physicsShape = SCNPhysicsShape(geometry: boxShape, options:nil)
                
                node.pivot = SCNMatrix4MakeTranslation(0, -min.y, 0)
                node.physicsBody = body
                scene.rootNode.addChildNode(node)
            }
        }
        
        //add smoke ParticleSystem
        let smokeHandle = scene.rootNode.childNode(withName: "Smoke", recursively: true)
        smokeHandle!.addParticleSystem(SCNParticleSystem(named: "smoke", inDirectory: nil)!)
        
        //add physics constraints between engine and wagons
        let engineCar = scene.rootNode.childNode(withName: "EngineCar", recursively: false)
        let wagon1 = scene.rootNode.childNode(withName: "Wagon1", recursively: false)
        let wagon2 = scene.rootNode.childNode(withName: "Wagon2", recursively: false)
        
        let (min, max) = engineCar!.boundingBox
        
        let (wmin, wmax) = wagon1!.boundingBox
        
        // Tie EngineCar & Wagon1
        var joint = SCNPhysicsBallSocketJoint(bodyA: engineCar!.physicsBody!, anchorA: SCNVector3Make(max.x, min.y, 0),
                                              bodyB: wagon1!.physicsBody!, anchorB: SCNVector3Make(wmin.x, wmin.y, 0))
        scene.physicsWorld.addBehavior(joint)
        
        // Wagon1 & Wagon2
        joint = SCNPhysicsBallSocketJoint(bodyA: wagon1!.physicsBody!, anchorA: SCNVector3Make(wmax.x + 0.1, wmin.y, 0),
                                          bodyB: wagon2!.physicsBody!, anchorB: SCNVector3Make(wmin.x - 0.1, wmin.y, 0))
        scene.physicsWorld.addBehavior(joint)
    }
    
    func addBallToScene(_ scene: SCNScene){
        // add ball
        let ball = SCNNode()
        ball.position = SCNVector3Make(-5, 5, -18)
        ball.geometry = SCNSphere(radius: 5)
        ball.geometry!.firstMaterial!.locksAmbientWithDiffuse = true
        ball.geometry!.firstMaterial!.diffuse.contents = "ball.jpg"
        ball.geometry!.firstMaterial!.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 1, 1)
        ball.geometry!.firstMaterial!.diffuse.wrapS = .mirror
        ball.physicsBody = SCNPhysicsBody.dynamic()
        ball.physicsBody!.restitution = 0.9
        scene.rootNode.addChildNode(ball)
    }
    
    func addWoodenBlockToScene_all(_ scene: SCNScene){
        // add wooden blocks
        addWoodenBlockToScene(scene, withImageNamed: "WoodCubeA.jpg", atPosition: SCNVector3Make(-10, 15, 10))
        addWoodenBlockToScene(scene, withImageNamed: "WoodCubeB.jpg", atPosition: SCNVector3Make(-9, 10, 10))
        addWoodenBlockToScene(scene, withImageNamed: "WoodCubeC.jpg", atPosition: SCNVector3Make(20, 15, -11))
        addWoodenBlockToScene(scene, withImageNamed: "WoodCubeA.jpg", atPosition: SCNVector3Make(25 , 5, -20))
        
        //add more wooden block
        for _ in 0 ..< 4 {
            addWoodenBlockToScene(scene, withImageNamed: "WoodCubeA.jpg", atPosition: SCNVector3Make(Float(arc4random_uniform(60)) - 30, 20, Float(arc4random_uniform(40)) - 20))
            addWoodenBlockToScene(scene, withImageNamed: "WoodCubeB.jpg", atPosition: SCNVector3Make(Float(arc4random_uniform(60)) - 30, 20, Float(arc4random_uniform(40)) - 20))
            addWoodenBlockToScene(scene, withImageNamed: "WoodCubeC.jpg", atPosition: SCNVector3Make(Float(arc4random_uniform(60)) - 30, 20, Float(arc4random_uniform(40)) - 20))
        }
    }
    func addWoodenBlockToScene(_ scene:SCNScene, withImageNamed imageName:NSString, atPosition position:SCNVector3) {
        //create a new node
        let block = SCNNode()
        
        //place it
        block.position = position
        
        //attach a box of 5x5x5
        block.geometry = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0)
        
        //use the specified images named as the texture
        block.geometry!.firstMaterial!.diffuse.contents = imageName
        
        //turn on mipmapping
        block.geometry!.firstMaterial!.diffuse.mipFilter = .linear
        
        //make it physically based
        block.physicsBody = SCNPhysicsBody.dynamic()
        
        //add to the scene
        scene.rootNode.addChildNode(block)
    }
    
    
    
}
