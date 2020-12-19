//
//  GameVC+InitScene.swift
//  SceneKitVehicle
//
//  Created by 龚晨杰 on 2020/11/28.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit


extension GameViewController
{
    

    
    func initScene(_ scene: SCNScene){

        let scnView = view as! GameView
        
        //set the background to back
        scnView.backgroundColor = SKColor.black
        
        
        //present it
        scnView.scene = scene
        
        // 世界的 重力系数
        scene.physicsWorld.gravity = SCNVector3Make(0.0, -9.8, 0);
        scene.physicsWorld.contactDelegate = self
        //tweak physics , 游戏进行速度，整体设置
        scnView.scene!.physicsWorld.speed = 3.0
        
        //setup overlays
        scnView.overlaySKScene = OverlayScene(size: scnView.bounds.size)
        

        //initial point of view
        scnView.pointOfView = _cameraNode
        
        //plug game logic
        scnView.delegate = self
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 2
        scnView.gestureRecognizers = [doubleTap]
        
        
    }
    

}
