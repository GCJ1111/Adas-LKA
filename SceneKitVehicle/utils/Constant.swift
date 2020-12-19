//
//  Constant.swift
//  SceneKitVehicle
//
//  Created by 龚晨杰 on 2020/11/28.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit



let MAX_SPEED: CGFloat = 250.0


let DEFAULT_PHY_BODY = 0b1 << 0 // 1
let CAR_PHY_BODY = 0b1 << 1     // 2
let LANE_PHY_BODY = 0b1 << 2    // 4
let BOX_PHY_BODY = 0b1 << 8     // 256
