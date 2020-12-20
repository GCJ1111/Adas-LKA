//
//  GameVC+ContactLogic.swift
//  SceneKitVehicle
//
//  Created by 龚晨杰 on 2020/12/19.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

extension GameViewController: SCNPhysicsContactDelegate
{
    static var car_contact_cnt:Int = 0
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact)
    {
        GLogSimple("contact 次数 ---- \(GameViewController.car_contact_cnt)" )
        GLogSimple("nodeA:\(contact.nodeA.name)-\(contact.nodeA.physicsBody?.categoryBitMask)")
        GLogSimple("nodeB:\(contact.nodeB.name)-\(contact.nodeB.physicsBody?.categoryBitMask)")
        if (contact.nodeA.physicsBody?.categoryBitMask == CAR_PHY_BODY ||
                contact.nodeB.physicsBody?.categoryBitMask == CAR_PHY_BODY){
            // 如果发生 接触的两个 node中，任意一个是 CAR
            GameViewController.car_contact_cnt += 1
            GLogSimple("小车 与 Box 相撞\n\n")

        }
    }
}
