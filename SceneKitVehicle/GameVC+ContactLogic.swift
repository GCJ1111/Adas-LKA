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
        GLog("contact 次数 ---- \(GameViewController.car_contact_cnt)" )
        GLog("nodeA:,\(contact.nodeA.physicsBody?.categoryBitMask)")
        GLog("nodeB:,\(contact.nodeB.physicsBody?.categoryBitMask)")
        if (contact.nodeA.physicsBody?.categoryBitMask == CAR_PHY_BODY ||
                contact.nodeB.physicsBody?.categoryBitMask == CAR_PHY_BODY){
            // 如果发生 接触的两个 node中，任意一个是 CAR
            GameViewController.car_contact_cnt += 1
            GLog("小车与 box 相撞\n\n")

        }
    }
}
