//
//  GameVC+AddBasicGeo.swift
//  SceneKitVehicle
//
//  Created by 龚晨杰 on 2020/12/19.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

extension GameViewController
{
    

    
    func addBox(_ scene:SCNScene, withImageNamed imageName:NSString, atPosition position:SCNVector3) {
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
        block.physicsBody?.mass = 10.0
        block.physicsBody?.categoryBitMask = BOX_PHY_BODY
        block.physicsBody?.contactTestBitMask = CAR_PHY_BODY
        //add to the scene
        block.name = "Box-A"
        
        let boxFireParticle: SCNParticleSystem!

        boxFireParticle = SCNParticleSystem(named: "reactor", inDirectory: nil)

        block.addParticleSystem(boxFireParticle)
        
        scene.rootNode.addChildNode(block)
    }
    
    func addBoxMulti(_ scene: SCNScene){
        for _ in 0 ..< 4 {
            addBox(scene, withImageNamed: "WoodCubeA.jpg", atPosition: SCNVector3Make(Float(arc4random_uniform(60)) - 30, 20, Float(arc4random_uniform(40)) - 20))
            addBox(scene, withImageNamed: "WoodCubeB.jpg", atPosition: SCNVector3Make(Float(arc4random_uniform(60)) - 30, 20, Float(arc4random_uniform(40)) - 20))
            addBox(scene, withImageNamed: "WoodCubeC.jpg", atPosition: SCNVector3Make(Float(arc4random_uniform(60)) - 30, 20, Float(arc4random_uniform(40)) - 20))
        }
        
    }
}
