//
//  Service.swift
//  WorldTracking
//
//  Created by Anita Stashevskaya on 29.07.2022.
//

import UIKit
import ARKit
final class DistanceCalculate {

    func addChild(_ node: SCNNode, to toNode: SCNNode, in inView: ARSCNView, for cameraRelativePosition: SCNVector3) {
        guard let currentFrame = inView.session.currentFrame else { return }
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = cameraRelativePosition.x
        translationMatrix.columns.3.y = cameraRelativePosition.y
        translationMatrix.columns.3.z = cameraRelativePosition.z
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        node.simdTransform = modifiedMatrix
        toNode.addChildNode(node)
    }

    func distance3(from fromStartingPositionNode: SCNNode?, on onView: ARSCNView, for cameraRelativePosition: SCNVector3) -> SCNVector3? {
        guard let startingPosition = fromStartingPositionNode, let currentFrame = onView.session.currentFrame else { return nil }
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = cameraRelativePosition.x
        translationMatrix.columns.3.y = cameraRelativePosition.y
        translationMatrix.columns.3.z = cameraRelativePosition.z
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        let xDistance = modifiedMatrix.columns.3.x - startingPosition.position.x
        let yDistance = modifiedMatrix.columns.3.y - startingPosition.position.y
        let zDistance = modifiedMatrix.columns.3.z - startingPosition.position.z
        return SCNVector3(xDistance, yDistance, zDistance)
    }
    
    func distance(x: Float, y: Float, z: Float) -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
}
