//
//  GameVC+VehDynm.swift
//  SceneKitVehicle
//
//  Created by 龚晨杰 on 2020/11/28.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

extension GameViewController{

    func setupVehicle(_ scene: SCNScene) -> SCNNode {
        // 导入 scene
        let carScene = SCNScene(named: "rc_car")!
        
        // 获取 scnce 中的 Node ， 得到一个 【SCNNode?】
        let chassisNode = carScene.rootNode.childNode(withName: "rccarBody", recursively: false)
        
        let chassisInfoNode = SCNNode(geometry: SCNPlane(width: 10.0, height: 10.0))
        chassisInfoNode.position = SCNVector3Make(10.0, 3.0, 0.0)
        chassisInfoNode.name = "chassisInfoNode"
        chassisNode!.addChildNode(chassisInfoNode)

        
        
        // 设置 车身的物理模型
        SetupChassisSystem(chassisNode: chassisNode)
        scene.rootNode.addChildNode(chassisNode!)
        
        // 设置 排气的粒子效果
        SetupPipeParticle(chassisNode: chassisNode)
    
        // 设置 轮胎的物理模型
        let wheelsPhys_array = SetupWheelSystem(chassisNode: chassisNode)
        
        // create the physics vehicle
        let vehiclePhyBehav = SCNPhysicsVehicle(chassisBody: chassisNode!.physicsBody!, wheels: wheelsPhys_array)
        scene.physicsWorld.addBehavior(vehiclePhyBehav)
        
        _playerVehPhyBehav = vehiclePhyBehav
        
        return chassisNode!
    }
    

    
    private func SetupChassisSystem(chassisNode: SCNNode?){
        
        // setup the chassis
        chassisNode!.position = SCNVector3Make(0, 10, 30)
        chassisNode!.rotation = SCNVector4Make(0, 1, 0, .pi)
        
        // setup phy body
        let body = SCNPhysicsBody.dynamic()
        body.allowsResting = false
        body.mass = 80.0
        body.restitution = 0.1
        body.friction = 0.5
        body.rollingFriction = 0
        
        // 设置 碰撞相关 属性
        body.categoryBitMask = CAR_PHY_BODY
//        body.contactTestBitMask |= BOX_PHY_BODY
//        body.contactTestBitMask |= LANE_PHY_BODY

        chassisNode!.physicsBody = body

        
    }
    
    private func SetupPipeParticle(chassisNode: SCNNode?){
        
        let pipeNode = chassisNode!.childNode(withName: "pipe", recursively: true)
        _reactor = SCNParticleSystem(named: "reactor", inDirectory: nil)
        _reactorDefaultBirthRate = _reactor.birthRate
//        _reactor.birthRate = 1000
        pipeNode!.addParticleSystem(_reactor)
        
        
    }
    
    private func SetupWheelSystem(chassisNode: SCNNode?) -> [SCNPhysicsVehicleWheel]{
        //get wheels node from ...
        let wheel0Node = chassisNode!.childNode(withName: "wheelLocator_FL", recursively: true)!
        let wheel1Node = chassisNode!.childNode(withName: "wheelLocator_FR", recursively: true)!
        let wheel2Node = chassisNode!.childNode(withName: "wheelLocator_RL", recursively: true)!
        let wheel3Node = chassisNode!.childNode(withName: "wheelLocator_RR", recursively: true)!
        
        wheel1Node.physicsBody =  SCNPhysicsBody.dynamic()
        // 设置 碰撞相关 属性
        wheel1Node.physicsBody?.categoryBitMask = FR_WHEEL_BODY


        wheel1Node.physicsBody?.contactTestBitMask |= LANE_PHY_BODY
        wheel1Node.physicsBody?.contactTestBitMask |= BOX_PHY_BODY
        wheel1Node.physicsBody?.contactTestBitMask |= CAR_PHY_BODY

        // 创建物理 Wheel
        let wheel0 = SCNPhysicsVehicleWheel(node: wheel0Node)
        let wheel1 = SCNPhysicsVehicleWheel(node: wheel1Node)
        let wheel2 = SCNPhysicsVehicleWheel(node: wheel2Node)
        let wheel3 = SCNPhysicsVehicleWheel(node: wheel3Node)

        let (min, max) = wheel0Node.boundingBox
        let wheelHalfWidth = Float(0.5 * (max.x - min.x))
        
        wheel0.connectionPosition = SCNVector3(SIMD3(wheel0Node.convertPosition(SCNVector3Zero, to: chassisNode)) + SIMD3(wheelHalfWidth, 0, 0))
        wheel1.connectionPosition = SCNVector3(SIMD3(wheel1Node.convertPosition(SCNVector3Zero, to: chassisNode)) - SIMD3(wheelHalfWidth, 0, 0))
        wheel2.connectionPosition = SCNVector3(SIMD3(wheel2Node.convertPosition(SCNVector3Zero, to: chassisNode)) + SIMD3(wheelHalfWidth, 0, 0))
        wheel3.connectionPosition = SCNVector3(SIMD3(wheel3Node.convertPosition(SCNVector3Zero, to: chassisNode)) - SIMD3(wheelHalfWidth, 0, 0))
        
        return [wheel0,wheel1,wheel2,wheel3]
    }
    
    
}
