//
//  ViewController.swift
//  WorldTracking
//
//  Created by Anita Stashevskaya on 19.07.2022.
//

import UIKit
import ARKit


final class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet private var sceneView: ARSCNView!
    private let worldTrackingConfiguration = ARWorldTrackingConfiguration()
    
    private var startingPositionNode: SCNNode?
    private var endingPositionNode: SCNNode?
    private let cameraRelativePosition = SCNVector3(x: 0, y: 0, z: -0.2) //-0.2
    private let xLabel = UILabel()
    private let yLabel = UILabel()
    private let zLabel = UILabel()
    private var distanceLabel = UILabel()
    private let distanceCalculate = DistanceCalculate()
        
    override func viewDidLoad() { //TODO: разгрузить
        super.viewDidLoad()
        
        let plusButton = UIButton()
        plusButton.setImage(UIImage(named: "plus.png"), for: .normal)
        plusButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(plusButton)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        distanceLabel.font = UIFont.boldSystemFont(ofSize: 14)
        distanceLabel.textColor = UIColor.black
        distanceLabel.text = "Distance: "
        self.view.addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        distanceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        let centerImageView = UIImageView()
        centerImageView.image = UIImage(named: "centerPlus.png")//TODO: попросить плюсик
        centerImageView.contentMode = .scaleAspectFill
        self.view.addSubview(centerImageView)
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        centerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centerImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        centerImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        worldTrackingConfiguration.planeDetection = .horizontal
        self.sceneView.session.run(worldTrackingConfiguration)
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
    }
    
    @objc private func buttonAction(sender: UIButton!) {
        handleTap()
    }

    override var prefersStatusBarHidden: Bool {
            return true
    }

    @objc private func handleTap() {
        if startingPositionNode != nil && endingPositionNode != nil {
            startingPositionNode?.removeFromParentNode()
            endingPositionNode?.removeFromParentNode()
            startingPositionNode = nil
            endingPositionNode = nil
        } else if startingPositionNode != nil && endingPositionNode == nil {
            let sphere = SCNNode(geometry: SCNSphere(radius: 0.003))
            sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
            //cameraRelativePosition
            distanceCalculate.addChild(sphere, to: sceneView.scene.rootNode, in: sceneView, for: cameraRelativePosition)
            endingPositionNode = sphere//MARK: add sphere as ending position
        } else if startingPositionNode == nil && endingPositionNode == nil {
            let sphere = SCNNode(geometry: SCNSphere(radius: 0.003))
            sphere.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "silver.jpeg") //TODO: Сложно читаемая проверка -> easy
            distanceCalculate.addChild(sphere, to: sceneView.scene.rootNode, in: sceneView, for: cameraRelativePosition)
            startingPositionNode = sphere//MARK: add sphere as starting position
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if startingPositionNode != nil && endingPositionNode != nil { return }
        
        guard let xDistance = distanceCalculate.distance3(from: startingPositionNode, on: sceneView, for: cameraRelativePosition)?.x else { return }
        guard let yDistance = distanceCalculate.distance3(from: startingPositionNode, on: sceneView, for: cameraRelativePosition)?.y else { return }
        guard let zDistance = distanceCalculate.distance3(from: startingPositionNode, on: sceneView, for: cameraRelativePosition)?.z else { return }
        
        DispatchQueue.main.async {
            self.xLabel.text = String(format: "x: %.2f", xDistance) + "m"
            self.yLabel.text = String(format: "y: %.2f", yDistance) + "m"
            self.zLabel.text = String(format: "z: %.2f", zDistance) + "m"
            
            self.distanceLabel.text = String(format: "Distance: %.2f", self.distanceCalculate.distance(x: xDistance, y: yDistance, z: zDistance))
        }
    }

}

