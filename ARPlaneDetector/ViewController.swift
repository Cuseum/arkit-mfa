//
//  ViewController.swift
//  ARPlaneDetector
//
//  Created by Ben Lambert on 2/8/18.
//  Copyright © 2018 collectiveidea. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!

    
    @IBOutlet weak var trailingC: NSLayoutConstraint!
    
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    
    @IBOutlet weak var but_0: UIButton!
    @IBOutlet weak var but_1: UIButton!
    
    var tag = -1
    
    let sceneManager = ARSceneManager()
    
    
    @IBAction func button_press(_ sender: UIButton) {
        
        print("painting")
        print(sender.tag)
        tag = sender.tag
    }
    
    @IBOutlet weak var restartExperienceButton: UIBarButtonItem!
    
    @IBAction func restartExperience(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            let children = self.sceneView.scene.rootNode.childNodes
            for node in children {
                node.removeFromParentNode()
            }
        }
        
        sceneManager.showPlanes = true
    }
    
    
    var hamburgerMenuIsVisible = false
    @IBAction func hamburgerBtnTapped(_ sender: Any) {
        //if the hamburger menu is NOT visible, then move the ubeView back to where it used to be
        if !hamburgerMenuIsVisible {
            leadingC.constant = 400
            //this constant is NEGATIVE because we are moving it 150 points OUTWARD and that means -150
            trailingC.constant = -400
            
            //1
            hamburgerMenuIsVisible = true
        } else {
            //if the hamburger menu IS visible, then move the ubeView back to its original position
            leadingC.constant = 0
            trailingC.constant = 0
            
            //2
            hamburgerMenuIsVisible = false
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager.attach(to: sceneView)
        
        sceneManager.displayDegubInfo()
        
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScene(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapScene(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            let location = gesture.location(ofTouch: 0,
                                            in: sceneView)
            let hit = sceneView.hitTest(location,
                                        types: .existingPlaneUsingGeometry)
            
            if let hit = hit.first {
                placeBlockOnPlaneAt(hit)
            }
        default:
            print("tapped default")
        }
    }
    
    func placeBlockOnPlaneAt(_ hit: ARHitTestResult) {
        let box = createBox()
        position(node: box, atHit: hit)
        
        sceneView?.scene.rootNode.addChildNode(box)
    }
    
    private func createBox() -> SCNNode {
        
        sceneManager.showPlanes = false
        
        var scn_file: String
        var direct: String
        scn_file = ""
        direct = ""
        
        switch tag {
            case 0:
                scn_file = "abstract_painting_00.scn"
                direct = "Models.scnassets/abstract_painting_00"
            
            case 1:
                scn_file = "abstract_painting_01.scn"
                direct = "Models.scnassets/abstract_painting_01"
            case 2:
                scn_file = "abstract_painting_02.scn"
                direct = "Models.scnassets/abstract_painting_02"
            case 3:
                scn_file = "abstract_painting_03.scn"
                direct = "Models.scnassets/abstract_painting_03"
            case 4:
                scn_file = "landscape_painting_00.scn"
                direct = "Models.scnassets/landscape_painting_00"
            case 5:
                scn_file = "landscape_painting_01.scn"
                direct = "Models.scnassets/landscape_painting_01"
            case 6:
                scn_file = "landscape_painting_02.scn"
                direct = "Models.scnassets/landscape_painting_02"
            case 7:
                scn_file = "landscape_painting_03.scn"
                direct = "Models.scnassets/landscape_painting_03"
            case 8:
                scn_file = "landscape_painting_04.scn"
                direct = "Models.scnassets/landscape_painting_04"
            case 9:
                scn_file = "figure_painting_00.scn"
                direct = "Models.scnassets/figure_painting_00"
            case 10:
                scn_file = "figure_painting_01.scn"
                direct = "Models.scnassets/figure_painting_01"
            case 11:
                scn_file = "figure_painting_02.scn"
                direct = "Models.scnassets/figure_painting_02"
            case 12:
                scn_file = "figure_painting_03.scn"
                direct = "Models.scnassets/figure_painting_03"
            case 13:
                scn_file = "figure_painting_04.scn"
                direct = "Models.scnassets/figure_painting_04"
            default:
                scn_file = "figure_painting_00.scn"
                direct = "Models.scnassets/abstract_painting_00"
        }
        
        
        let virtualObjectScene = SCNScene(named: scn_file, inDirectory: direct)

        let boxNode = SCNNode()

        for child in virtualObjectScene!.rootNode.childNodes {
                boxNode.addChildNode(child)
            }
        
        return boxNode
    }
    
    private func position(node: SCNNode, atHit hit: ARHitTestResult) {
        node.transform = SCNMatrix4(hit.anchor!.transform)
        node.eulerAngles = SCNVector3Make(node.eulerAngles.x + (Float.pi / 2), node.eulerAngles.y, node.eulerAngles.z)
        
        
        //+ node.geometry!.boundingBox.min.z
        
        let position = SCNVector3Make(hit.worldTransform.columns.3.x, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
        node.position = position
    }

    @IBAction func tappedShoot(_ sender: Any) {
        let camera = sceneView.session.currentFrame!.camera
        let projectile = Projectile()
        
        // transform to location of camera
        var translation = matrix_float4x4(projectile.transform)
        translation.columns.3.z = -0.1
        translation.columns.3.x = 0.03
        
        projectile.simdTransform = matrix_multiply(camera.transform, translation)
        
        let force = simd_make_float4(-1, 0, -3, 0)
        let rotatedForce = simd_mul(camera.transform, force)
        
        let impulse = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)

        sceneView?.scene.rootNode.addChildNode(projectile)
        
        projectile.launch(inDirection: impulse)
    }
    
    @IBAction func tappedShowPlanes(_ sender: Any) {
        sceneManager.showPlanes = true
    }
    
    @IBAction func tappedHidePlanes(_ sender: Any) {
        sceneManager.showPlanes = false
    }
    
    @IBAction func tappedStop(_ sender: Any) {
        sceneManager.stopPlaneDetection()
    }
    
    @IBAction func tappedStart(_ sender: Any) {
        sceneManager.startPlaneDetection()
    }
    
}

class Projectile: SCNNode {
    
    override init() {
        super.init()
        
        let capsule = SCNCapsule(capRadius: 0.006, height: 0.06)
        
        geometry = capsule
        
        eulerAngles = SCNVector3(CGFloat.pi / 2, (CGFloat.pi * 0.25), 0)
        
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func launch(inDirection direction: SCNVector3) {
        physicsBody?.applyForce(direction, asImpulse: true)
    }
    
}
