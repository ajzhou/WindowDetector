//
//  RectangleNode.swift
//  ARKitRectangleDetection
//
//  Created by Melissa Ludowise on 8/3/17.
//  Copyright © 2017 Mel Ludowise. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

private let meters2inches = CGFloat(39.3701)

class RectangleNode: SCNNode {
    
    convenience init(_ planeRectangle: PlaneRectangle) {
        self.init(center: planeRectangle.position,
        width: planeRectangle.size.width,
        height: planeRectangle.size.height,
        orientation: planeRectangle.orientation,
        normalVector: planeRectangle.normalVector)
    }
    
    init(center position: SCNVector3, width: CGFloat, height: CGFloat, orientation: Float, normalVector: SCNVector3) {
        super.init()
        
        // Debug
        print("position: \(position) width: \(width) (\(width * meters2inches)\") height: \(height) (\(height * meters2inches)\")")
        
        // Create the 3D plane geometry with the dimensions calculated from corners
        let planeGeometry = SCNPlane(width: width, height: height)
    
        let rectNode = SCNNode(geometry: planeGeometry)
//        rectNode.geometry?.firstMaterial?.isDoubleSided = true
        
        // Planes in SceneKit are vertical by default so we need to rotate
        // 90 degrees to match planes in ARKit
//        var transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1.0, 0.0, 0.0)
        
        print("NORMAL VECTOR: \(normalVector)")
        print("ORIENTATION: \(orientation)")
        
       var transform = SCNMatrix4MakeRotation(-Float.pi / 2, 0.0, 0.0, 1.0)
        // Set rotation to the corner of the rectangle
        transform = SCNMatrix4Rotate(transform, orientation, 0, 1, 0)
        
        rectNode.transform = transform
        rectNode.geometry?.firstMaterial?.isDoubleSided = true
        
        // We add the new node to ourself since we inherited from SCNNode
        self.addChildNode(rectNode)
        
        // Set position to the center of rectangle
        self.position = position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}


