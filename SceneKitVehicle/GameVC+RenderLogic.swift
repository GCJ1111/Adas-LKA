//
//  GameVC+RenderLogic.swift
//  SceneKitVehicle
//
//  Created by 龚晨杰 on 2020/11/28.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import GameController


extension GameViewController: SCNSceneRendererDelegate
{
    // game logic
    func renderer(_ aRenderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        
    
        let defaultEngineForce: CGFloat = 300.0
        let defaultBrakingForce: CGFloat = 3.0
        let steeringClamp: CGFloat = 0.6
        let cameraDamping: CGFloat = 0.3
        
        let scnView = view as! GameView
        
        var engineForce: CGFloat = 0
        var brakingForce: CGFloat = 0
        
        let controllers = GCController.controllers()
        
        var orientation = _orientation
        
        //drive: 1 touch = accelerate, 2 touches = backward, 3 touches = brake
        if scnView.touchCount == 1 {
            engineForce = defaultEngineForce
            _reactor.birthRate = _reactorDefaultBirthRate
        } else if scnView.touchCount == 2 {
            engineForce = -defaultEngineForce
            _reactor.birthRate = 0
        } else if scnView.touchCount == 3 {
            brakingForce = 100
            _reactor.birthRate = 0
        } else {
            brakingForce = defaultBrakingForce
            _reactor.birthRate = 0
        }
        
        //controller support,  仅为了外部 游戏控制器
        if !controllers.isEmpty {
            let controller = controllers[0]
            let pad = controller.gamepad!
            let dpad = pad.dpad
            
            struct My {
                static var orientationCum: CGFloat = 0
            }
            
            let INCR_ORIENTATION: CGFloat = 0.03
            let DECR_ORIENTATION: CGFloat = 0.8
            
            if dpad.right.isPressed {
                if My.orientationCum < 0 {
                    My.orientationCum *= DECR_ORIENTATION
                }
                My.orientationCum += INCR_ORIENTATION
                if My.orientationCum > 1 {
                    My.orientationCum = 1
                }
            } else if dpad.left.isPressed {
                if My.orientationCum > 0 {
                    My.orientationCum *= DECR_ORIENTATION
                }
                My.orientationCum -= INCR_ORIENTATION
                if My.orientationCum < -1 {
                    My.orientationCum = -1
                }
            } else {
                My.orientationCum *= DECR_ORIENTATION
            }
            
            orientation = My.orientationCum
            
            if pad.buttonX.isPressed {
                engineForce = defaultEngineForce
                _reactor.birthRate = _reactorDefaultBirthRate
            } else if pad.buttonA.isPressed {
                engineForce = -defaultEngineForce
                _reactor.birthRate = 0
            } else if pad.buttonB.isPressed {
                brakingForce = 100
                _reactor.birthRate = 0
            } else {
                brakingForce = defaultBrakingForce
                _reactor.birthRate = 0
            }
        }
        
//        _vehicleSteering = -orientation
        
        /**
         # Debug
         */
//        _vehicleSteering = -0.05
        if orientation == 0 {
            _vehicleSteering *= 0.9
        }
        if _vehicleSteering < -steeringClamp {
            _vehicleSteering = -steeringClamp
        }
        if _vehicleSteering > steeringClamp {
            _vehicleSteering = steeringClamp
        }
        
        //update the vehicle steering and acceleration
        _playerVehPhyBehav.setSteeringAngle(_vehicleSteering, forWheelAt: 0)
        _playerVehPhyBehav.setSteeringAngle(_vehicleSteering, forWheelAt: 1)
        
        _playerVehPhyBehav.applyEngineForce(engineForce, forWheelAt: 2)
        _playerVehPhyBehav.applyEngineForce(engineForce, forWheelAt: 3)
        
        _playerVehPhyBehav.applyBrakingForce(brakingForce, forWheelAt: 2)
        _playerVehPhyBehav.applyBrakingForce(brakingForce, forWheelAt: 3)
        
        //check if the car is upside down
        reorientCarIfNeeded()
        
        // make camera follow the car node
        let car = _playerVehNode.presentation
        let carPos = car.position
        let targetPos = SIMD3(carPos.x, Float(30), carPos.z + 25)
        //        var cameraPos = float3(_cameraNode.position)
        var cameraPos = SIMD3(_cameraNode.position.x,_cameraNode.position.y,_cameraNode.position.z)
        
        cameraPos = mix(cameraPos, targetPos, t: Float(cameraDamping))
        _cameraNode.position = SCNVector3(cameraPos)
        
        if scnView.inCarView {
            //move spot light in front of the camera
            let frontPosition = scnView.pointOfView!.presentation.convertPosition(SCNVector3Make(0, 0, -30), to:nil)
            _spotLightNode.position = SCNVector3Make(frontPosition.x, 80, frontPosition.z)
            _spotLightNode.rotation = SCNVector4Make(1,0,0,-Float.pi/2)
        } else {
            //move spot light on top of the car
            _spotLightNode.position = SCNVector3Make(carPos.x, 80, carPos.z + 30)
            _spotLightNode.rotation = SCNVector4Make(1,0,0,-Float.pi/2.8)
        }
        
        //speed gauge. 车速仪表显示， 指针绕 Z轴 旋转
        let overlayScene = scnView.overlaySKScene as! OverlayScene
        overlayScene.speedNeedle.zRotation = -(_playerVehPhyBehav.speedInKilometersPerHour * .pi / MAX_SPEED)
        
        // 车速显示
        if (_playerVehPhyBehav.speedInKilometersPerHour > 80) {
            _playerVehNode.childNode(withName: "chassisInfoNode", recursively: true)?.isHidden = false
        }
        else
        {
            _playerVehNode.childNode(withName: "chassisInfoNode", recursively: true)?.isHidden = true


            
        }
    }
    
    
    private func reorientCarIfNeeded() {
        let car = _playerVehNode.presentation
        let carPos = car.position
        
        // make sure the car isn't upside down, and fix it if it is
        struct My {
            static var ticks = 0
            static var check = 0
            static var `try` = 0
        }
        func randf() -> Float {
            return Float(arc4random())/Float(UInt32.max)
        }
        My.ticks += 1
        if My.ticks == 30 {
            let t = car.worldTransform
            if t.m22 <= 0.1 {
                My.check += 1
                if My.check == 3 {
                    My.try += 1
                    if My.try == 3 {
                        My.try = 0
                        
                        //hard reset
                        _playerVehNode.rotation = SCNVector4Make(0, 0, 0, 0)
                        _playerVehNode.position = SCNVector3Make(carPos.x, carPos.y + 10, carPos.z)
                        _playerVehNode.physicsBody!.resetTransform()
                    } else {
                        //try to upturn with an random impulse
                        let pos = SCNVector3Make(-10 * (randf() - 0.5), 0, -10 * (randf() - 0.5))
                        _playerVehNode.physicsBody!.applyForce(SCNVector3Make(0, 300, 0), at: pos, asImpulse: true)
                    }
                    
                    My.check = 0
                }
            } else {
                My.check = 0
            }
            
            My.ticks = 0
        }
    }

}
