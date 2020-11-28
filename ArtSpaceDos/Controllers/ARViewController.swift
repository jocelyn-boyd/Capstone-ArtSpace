//
//  ARViewController.swift
//  ArtSpaceDos
//
//  Created by Levi Davis on 2/6/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit
import ARKit
import Kingfisher

private enum ARState: Int16 {
    case isActive
    case isNotActive
}

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    private var arState: ARState = .isActive
    
    var artObject: ArtObject!
    private var imageToDisplay: UIImage? = nil
    
    private var basePlane = SCNNode()
    private var artBox = SCNNode()
    
    private var status: String = "Looking for Surface" {
        didSet {
            DispatchQueue.main.async {
                self.statusLabel.text = self.status
            }
        }
    }
    
    //    MARK: - Instantiate UI Elements
    
    lazy var sceneView: ARSCNView = {
        let arView = ARSCNView()
        
        return arView
    }()
    
    lazy var resetButton: UIButton = {
        let resetButton = UIButton()
        resetButton.setTitle("RESET", for: .normal)
        resetButton.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
        return resetButton
    }()
    
    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = self.status
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    //    MARK: - Lifecycle Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        constrainSubviews()
        initializeSceneView()
        initializeARSession()
        initializeGestureRecognizer()
        retrieveImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.session.pause()
    }
    
    //    MARK: - @Objc-Methods
    
    @objc private func resetButtonPressed(sender: UIButton) {
        resetARSession()
        removeNodes()
        status = "Looking for Surface"
    }
    
    //    Adds box with image on it when scene is tapped, as long as there is a plane on it
    
    @objc private func screenTapped(sender: UITapGestureRecognizer) {
        let tappedScene = sender.view as! ARSCNView
        tappedScene.isUserInteractionEnabled = true
        let tapLocation = sender.location(in: tappedScene)
        let planeIntersections = tappedScene.hitTest(tapLocation, types: .existingPlane)
        if !planeIntersections.isEmpty {
            
            let transform = planeIntersections.last!.worldTransform
            let positionColumn = transform.columns.3
            let initialPosition = SCNVector3(positionColumn.x,
                                             positionColumn.y,
                                             positionColumn.z - 0.25)
            
            drawArtBox(initialPosition: initialPosition)
            
            basePlane.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            
        }
        
    }
    
    
    //    MARK: - Private Methods
    
    
    private func retrieveImage() {
        guard let url = URL.init(string: artObject.artImageURL) else {return}
        KingfisherManager.shared.retrieveImage(with: url) { (result) in
            let image = try? result.get().image
            if let image = image {
                self.imageToDisplay = image
            }
        }
    }
    
    //    Initialize sceneView and ARSession
    
    private func initializeSceneView() {
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.showsStatistics = true
        sceneView.preferredFramesPerSecond = 60
        sceneView.antialiasingMode = .multisampling2X
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    //    Break configuration out into its own function, because it gets called more than once
    
    private func createARConfiguration() -> ARConfiguration {
        let config = ARWorldTrackingConfiguration()
        
        config.worldAlignment = .gravity
        config.planeDetection = [.horizontal, .vertical]
        config.isLightEstimationEnabled = true
        
        return config
    }
    
    private func initializeARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {status = "AR World Tracking Not Supported"; return}
        
        let config = createARConfiguration()
        arState = .isActive
        sceneView.session.run(config)
    }
    
    //    Reset the session and scene
    
    private func resetARSession() {
        let config = createARConfiguration()
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        arState = .isActive
    }
    
    private func removeNodes() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
    }
    
    //    Initialize gesture recognizer
    
    private func initializeGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        sceneView.addGestureRecognizer(tapGesture)
        print("Tap Initialized")
    }
    
    //    Draw a box with image on the first face
    
    private func drawArtBox(initialPosition: SCNVector3) {
        
        artBox = SCNNode(geometry: SCNBox(width: artObject.width,
                                          height: artObject.height,
                                          length: 0.06,
                                          chamferRadius: 0.5))
        
        artBox.position = initialPosition
        
        let sideOne = SCNMaterial()
        sideOne.diffuse.contents = imageToDisplay
        sideOne.lightingModel = .blinn
        sideOne.diffuse.intensity = 0.75
        let otherSides = SCNMaterial()
        otherSides.diffuse.contents = UIColor.black
        
        artBox.geometry?.materials = [sideOne, otherSides, otherSides, otherSides, otherSides, otherSides]
        sceneView.scene.rootNode.addChildNode(artBox)
        status = "Do you like it?"
        
    }
    
    //    MARK: - Constrain UI Elements
    
    private func addSubviews() {
        view.addSubview(sceneView)
        sceneView.addSubview(resetButton)
        sceneView.addSubview(statusLabel)
    }
    
    private func constrainSubviews() {
        constrainSceneView()
        constrainResetButton()
        constrainStatusLabel()
    }
    
    private func constrainSceneView() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        [sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         sceneView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         sceneView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
         sceneView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)].forEach{$0.isActive = true}
        
    }
    
    private func constrainResetButton() {
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        [resetButton.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor),
         resetButton.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor),
         resetButton.heightAnchor.constraint(equalToConstant: 50),
         resetButton.widthAnchor.constraint(equalToConstant: 75)].forEach{$0.isActive = true}
    }
    
    private func constrainStatusLabel() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [statusLabel.centerXAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.centerXAnchor),
         statusLabel.topAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor, constant: 20),
         statusLabel.widthAnchor.constraint(equalToConstant: sceneView.safeAreaLayoutGuide.layoutFrame.width - 20)].forEach {$0.isActive = true}
    }
    
}

extension ARViewController {
    
    //    MARK: - APP Status
    
    //    Helper messages that can be displayed to the user. Apple reccomends doing this.
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            self.status = "For some reason, augmented reality tracking isn’t available."
        case .normal:
            
            if arState == .isActive {
                self.status = "Looking for Surface"
            }
            
        case .limited(let reason):
            
            if arState == .isActive {
                switch reason {
                case .excessiveMotion:
                    self.status = "You’re moving the device around too quickly. Slow down."
                case .insufficientFeatures:
                    self.status = "I can’t get a sense of the room. Is something blocking the rear camera?"
                case .initializing:
                    self.status = "Initializing — please wait a moment..."
                case .relocalizing:
                    self.status = "Relocalizing — please wait a moment..."
                @unknown default:
                    self.status = "Unknown error"
                    print("Unknown default")
                }
            }
        }
    }
    
    private func isAnyPlaneInView() -> Bool {
        let screenDivisions = 5 - 1
        let viewWidth = view.bounds.size.width
        let viewHeight = view.bounds.size.height
        
        //       Break screen into 5 x 5 divisions and perform a hit test on each one
        
        for y in 0...screenDivisions {
            let yCoord = CGFloat(y) / CGFloat(screenDivisions) * viewHeight
            for x in 0...screenDivisions {
                let xCoord = CGFloat(x) / CGFloat(screenDivisions) * viewWidth
                let point = CGPoint(x: xCoord, y: yCoord)
                
                let hitTest = sceneView.hitTest(point, types: .estimatedHorizontalPlane)
                
                if !hitTest.isEmpty {
                    return true
                }
            }
            
        }
        return false
    }
    
    //    MARK: - Plane Detection
    
    //      Gets called every time the node for a new anchor get added
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        if arState == .isActive {
            if planeAnchor.alignment == .vertical {
                drawPlaneNode(on: node, for: planeAnchor)
            }
        }
        
    }
    
    private func drawPlaneNode(on node: SCNNode, for planeAnchor: ARPlaneAnchor) {
        
        basePlane = SCNNode(geometry: SCNPlane(width: 2.5, height: 2.5))
        basePlane.position = SCNVector3(planeAnchor.center.x,
                                        planeAnchor.center.y,
                                        planeAnchor.center.z - 0.5)
        basePlane.geometry?.firstMaterial?.isDoubleSided = true
        basePlane.eulerAngles = SCNVector3(-Double.pi/2, 0, 0)
        
        if planeAnchor.alignment == .vertical {
            //   If a vertical plane is detected, draw a SCNPlane over it for the hitTest, but make it clear.
            basePlane.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            node.addChildNode(basePlane)
            
            status = "Wall Detected. Tap to Place Art"
        }
        
        arState = .isNotActive
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        //        Gets called if node corresponding to anchor is removed
        guard anchor is ARPlaneAnchor else {return}
        //        Remove child nodes
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
    // MARK: - AR session error management
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        status = "AR session failure: \(error)"
        resetARSession()
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        status = "AR session was interrupted!"
        resetARSession()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        status = "AR session interruption ended."
        resetARSession()
    }
    
}
