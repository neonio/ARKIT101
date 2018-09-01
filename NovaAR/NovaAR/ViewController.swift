//
//  ViewController.swift
//  NovaAR
//
//  Created by amoyio on 2018/8/30.
//  Copyright © 2018年 amoyio. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    var screenCenter: CGPoint!
    var modelsInTheScene: Array<SCNNode> = []
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    var focusSquare: FocusSquare?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showFeaturePoints]
        // Set the scene to the view
        screenCenter = view.center
        actionButton.addTarget(self, action: #selector(addObject), for: .touchUpInside)
    }
    
    @objc func addObject() {
        guard focusSquare != nil else {return}
        guard let modelNode = generateModel(name: "shell") else {
            return
        }
        modelsInTheScene.append(modelNode)
        sceneView.scene.rootNode.addChildNode(modelNode)
        let hitTest = sceneView.hitTest(screenCenter, types: .existingPlaneUsingExtent)
        guard let worldTransformColumn3 = hitTest.first?.worldTransform.columns.3 else {return}
        modelNode.position = SCNVector3(worldTransformColumn3.x, worldTransformColumn3.y, worldTransformColumn3.z)
    }
    
    private func generateModel(name: String) -> SCNNode?{
        let scene = SCNScene(named: "art.scnassets/\(name).scn")!
        guard let model = scene.rootNode.childNode(withName: "shell", recursively: true) else {
            return nil
        }
        model.name = name
        return model
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        screenCenter = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

}
extension ViewController :ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let focusSquareLocal = focusSquare else { return }
        let hitTest = sceneView.hitTest(screenCenter, types: .existingPlane)
        if let result = hitTest.first {
            let worldTransform = result.worldTransform
            let position = worldTransform.columns.3
            focusSquareLocal.position = SCNVector3(position.x, position.y, position.z)
        }
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            guard focusSquare == nil else {return}
            let focusSquareLocal = FocusSquare()
            sceneView.scene.rootNode.addChildNode(focusSquareLocal)
            self.focusSquare = focusSquareLocal
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        if let planeAnchor = anchor as? ARPlaneAnchor {
//            node.enumerateChildNodes { (childNode, _) in
//                childNode.removeFromParentNode()
//            }
//            let planeNode = createPlane(anchor: planeAnchor)
//            node.addChildNode(planeNode)
//        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let _ = anchor as? ARPlaneAnchor {

//            node.enumerateChildNodes { (childNode, _) in
//                childNode.removeFromParentNode()
//            }
        }
    }
    
    private func updateFocusSquare() {
        guard let focusSquareLocal = focusSquare else {return}
        let hitTest = sceneView.hitTest(screenCenter, types: .existingPlaneUsingExtent)
        if let _ = hitTest.first {
            focusSquareLocal.isDetect = true
        } else {
            focusSquareLocal.isDetect = false
        }
        guard let pointOfView = sceneView.pointOfView else {return}
        let firstVisibleModel = modelsInTheScene.first { (node) -> Bool in
            return sceneView.isNode(node, insideFrustumOf: pointOfView)
        }
        let modelsAreVisible = firstVisibleModel != nil
        
        if modelsAreVisible != focusSquareLocal.isHidden {
            focusSquareLocal.setHidden(to: modelsAreVisible)
        }
    }
    
    private func createPlane(anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        plane.firstMaterial?.diffuse.contents = UIImage(named: "")
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        //默认 plane 是竖着的
        planeNode.eulerAngles.x = GLKMathDegreesToRadians(-90)
        return planeNode
    }
}
