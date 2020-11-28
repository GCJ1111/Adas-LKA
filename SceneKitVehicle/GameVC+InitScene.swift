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

        let scnView = view as! SCNView
        
        //set the background to back
        scnView.backgroundColor = SKColor.black
        
        
        //present it
        scnView.scene = scene
        
        //tweak physics
        scnView.scene!.physicsWorld.speed = 4.0
        
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
