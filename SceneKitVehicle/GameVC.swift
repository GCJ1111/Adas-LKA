//
//  GameViewController.swift
//  SceneKitVehicle
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/08/17.
//  Copyright (c) 2014年 Apple Inc. All rights reserved.
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  A view controller that conforms to SCNSceneRendererDelegate and implements the game logic.

 */

import UIKit
import SpriteKit
import SceneKit
import GameController
import simd
import CoreMotion

//--Global constants
//let π = M_PI
//let π_2 = M_PI_2
//let π_4 = M_PI_4

@objc(AAPLGameViewController)
class GameViewController: UIViewController, SCNSceneRendererDelegate {
    //some node references for manipulation
    var _spotLightNode: SCNNode!
    var _cameraNode: SCNNode!          //the node that owns the camera
    var _playerVehNode: SCNNode!
    var _playerVehPhyBody: SCNPhysicsVehicle!
    
    var _reactor: SCNParticleSystem!
    
    //accelerometer
    var _motionManager: CMMotionManager!
    var _accelerometer = [UIAccelerationValue](repeating: 0.0, count: 3)
    var _orientation: CGFloat = 0.0
    
    //reactor's particle birth rate
    var _reactorDefaultBirthRate: CGFloat = 0.0
    
    // steering factor
    var _vehicleSteering: CGFloat = 0.0
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        UIApplication.shared.isStatusBarHidden = true
        
        //setup the scene
        let scene = setupScene()
        
        self.initScene(scene)
        
        //setup accelerometer
        self.setupAccelerometer()
        
        super.viewDidLoad()
        
        
        // 导入 scene
        

        
       
            
    }
    
    private func setupScene() -> SCNScene {
        // create a new scene
        let scene = SCNScene()
        
        //global environment
        setupEnvironment(scene)

        //add elements
        setupSceneElements(scene)

        //setup vehicle
        _playerVehNode = setupVehicle(scene)
        
        // setup Camera
        setupMainCamera(scene)
        setupSecondaryCamera(scene)
        
        
        return scene
    }
    
    
    
    
    private func setupEnvironment(_ scene: SCNScene) {
        // add an ambient light , 环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light!.type = SCNLight.LightType.ambient
        ambientLight.light!.color = UIColor(white: 0.3, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        //add a key light to the scene , spot 光
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.spot
        
        // 无论设备高端与否，显示 阴影
        if isHighEndDevice {
            lightNode.light!.castsShadow = true
        }
        else{
            lightNode.light!.castsShadow = true
        }
        
        lightNode.light!.color = UIColor(white: 0.8, alpha: 1.0)
        lightNode.position = SCNVector3Make(0, 80, 30)
        lightNode.rotation = SCNVector4Make(1, 0, 0, -Float.pi/2.8)
        lightNode.light!.spotInnerAngle = 0
        lightNode.light!.spotOuterAngle = 50
        lightNode.light!.shadowColor = SKColor.black
        lightNode.light!.zFar = 500
        lightNode.light!.zNear = 50
        scene.rootNode.addChildNode(lightNode)
        
        //keep an ivar for later manipulation
        _spotLightNode = lightNode
        
        //floor ， 地板
        let floor = SCNNode()
        floor.geometry = SCNFloor()
        floor.geometry!.firstMaterial!.diffuse.contents = "grass2.jpg"
//        floor.geometry!.firstMaterial!.diffuse.contents = UIColor.black

        floor.geometry!.firstMaterial!.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 2, 1) //scale the wood texture
        floor.geometry!.firstMaterial!.locksAmbientWithDiffuse = false

        // 无论设备高端 与否
        (floor.geometry as! SCNFloor).reflectionFalloffEnd = 10
//        (floor.geometry as! SCNFloor).reflectivity = 0.0

        // 静态 物理模型
        let staticBody = SCNPhysicsBody.static()
        floor.physicsBody = staticBody
        
        scene.rootNode.addChildNode(floor)
    }
    
    private func setupSceneElements(_ scene: SCNScene) {
        // add a train
//        addTrainToScene(scene, atPosition: SCNVector3Make(-5, 20, -40))
//
//        addWoodenBlockToScene_all(scene)
//
//        addWallToScene(scene)
//
//        addCartoonBookToScene(scene)
//
//        addCarpetToScene(scene)
//
//        addBallToScene(scene)
        
        
        addRoadToScene(scene)
        
    }
    

    
    private func setupMainCamera(_ scene: SCNScene){
        //create a main camera
        _cameraNode = SCNNode()
        _cameraNode.camera = SCNCamera()
        _cameraNode.camera!.zFar = 500
        _cameraNode.position = SCNVector3Make(0, 60, 50)
        _cameraNode.rotation  = SCNVector4Make(1, 0, 0, -Float.pi/4 * 0.75)
        scene.rootNode.addChildNode(_cameraNode)
        
    }
    private func setupSecondaryCamera(_ scene: SCNScene){
        //add a secondary camera to the car
        let frontCameraNode = SCNNode()
        frontCameraNode.position = SCNVector3Make(0, 3.5, 2.5)
        frontCameraNode.rotation = SCNVector4Make(0, 1, 0, .pi)
        frontCameraNode.camera = SCNCamera()
        //        frontCameraNode.camera!.xFov = 75
        frontCameraNode.camera!.fieldOfView = 75
        frontCameraNode.camera!.zFar = 500
        
        _playerVehNode.addChildNode(frontCameraNode)
        
    }
    
    

    override var prefersStatusBarHidden : Bool {
        return true
    }

    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let scene = setupScene()
        
        GLog("双击事件 - 触发")
        // TODO: 统一使用 initScene(_ scene: SCNScene)

        let scnView = view as! SCNView
        //present it
        scnView.scene = scene
        
        //tweak physics
        scnView.scene!.physicsWorld.speed = 4.0
        
        //initial point of view
        scnView.pointOfView = _cameraNode
        
        (scnView as! GameView).touchCount = 0
    }
    

   
    
    override func viewWillDisappear(_ animated: Bool) {
        _motionManager.stopAccelerometerUpdates()
        _motionManager = nil
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // 获取设备信息
    private lazy var deviceName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: systemInfo.machine) {machinePtr in
            String(cString: UnsafeRawPointer(machinePtr).assumingMemoryBound(to: CChar.self))
        }
    }()
    
    private var isHighEndDevice: Bool {
        //return YES for iPhone 5s and iPad air, NO otherwise
        return deviceName.hasPrefix("iPad4")
            || deviceName.hasPrefix("iPhone6")
            //### Added later devices...
            || deviceName.hasPrefix("iPad5")
            || deviceName.hasPrefix("iPad6")
            || deviceName.hasPrefix("iPad7")
            || deviceName.hasPrefix("iPad8")
            || deviceName.hasPrefix("iPhone7")
            || deviceName.hasPrefix("iPhone8")
            || deviceName.hasPrefix("iPhone9")
            || deviceName.hasPrefix("iPhone10")
            || deviceName.hasPrefix("iPhone11")
        
    }
    
    
}
