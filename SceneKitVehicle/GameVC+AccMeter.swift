//
//  GameVC+aaa.swift
//  SceneKitVehicle
//
//  Created by 龚晨杰 on 2020/11/28.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import CoreMotion
import GameController

extension GameViewController{
    
    func setupAccelerometer() {
        //event
        _motionManager = CMMotionManager()
        
        if GCController.controllers().count == 0 && _motionManager.isAccelerometerAvailable {
            _motionManager.accelerometerUpdateInterval = 1/60.0
            _motionManager.startAccelerometerUpdates(to: OperationQueue.main) {[weak self] accelerometerData, error in
                self!.accelerometerDidChange(accelerometerData!.acceleration)
            }
        }
    }
    
    
    func accelerometerDidChange(_ acceleration: CMAcceleration) {
        let kFilteringFactor = 0.5
        
        //Use a basic low-pass filter to only keep the gravity in the accelerometer values
        _accelerometer[0] = acceleration.x * kFilteringFactor + _accelerometer[0] * (1.0 - kFilteringFactor)
        _accelerometer[1] = acceleration.y * kFilteringFactor + _accelerometer[1] * (1.0 - kFilteringFactor)
        _accelerometer[2] = acceleration.z * kFilteringFactor + _accelerometer[2] * (1.0 - kFilteringFactor)
        
        if _accelerometer[0] > 0 {
            _orientation = CGFloat(_accelerometer[1] * 1.3)
        } else {
            _orientation = -CGFloat(_accelerometer[1] * 1.3)
        }
    }
}
