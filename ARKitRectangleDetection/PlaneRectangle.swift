//
//  PlaneRectangle.swift
//  ARKitRectangleDetection
//
//  Created by Melissa Ludowise on 8/5/17.
//  Copyright © 2017 Mel Ludowise. All rights reserved.
//

import Foundation
import ARKit
import Vision

class PlaneRectangle: NSObject {
    
    // Plane anchor this rectangle is attached to
//    private(set) var anchor: ARPlaneAnchor
    
    // Center position in 3D space
    private(set) var position: SCNVector3
    
    // Dimensions of the rectangle
    private(set) var size: CGSize
    
    // Orientation of the rectangle based on how much it's rotated around the y axis
    private(set) var orientation: Float
    private(set) var normalVector: SCNVector3
    
    // Creates a rectangleon 3D space based on a VNRectangleObservation found in a given ARSCNView
    // Returns nil if no plane can be found that contains the rectangle
    init?(for rectangle: VNRectangleObservation, in sceneView: ARSCNView) {
//        guard let cornersAndAnchor = getCorners(for: rectangle, in: sceneView) else {
//            return nil
//        }
        
        guard let corners = getCorners(for: rectangle, in: sceneView) else {
            return nil
        }
//        self.corners = cornersAndAnchor.corners
//        self.anchor = cornersAndAnchor.anchor
        self.position = corners.center
        self.size = CGSize(width: corners.width, height: corners.height)
        self.orientation = corners.orientation
        self.normalVector = corners.normalVector
    }
    
    init(anchor: ARPlaneAnchor, position: SCNVector3, size: CGSize, orientation: Float, normalVector: SCNVector3) {
//        self.anchor = anchor
        self.position = position
        self.size = size
        self.orientation = orientation
        self.normalVector = normalVector
        super.init()
    }
    
    private override init() {
        fatalError("Not implemented")
    }
}

fileprivate enum RectangleCorners {
    case topLeft(topLeft: SCNVector3, topRight: SCNVector3, bottomLeft: SCNVector3)
    case topRight(topLeft: SCNVector3, topRight: SCNVector3, bottomRight: SCNVector3)
    case bottomLeft(topLeft: SCNVector3, bottomLeft: SCNVector3, bottomRight: SCNVector3)
    case bottomRight(topRight: SCNVector3, bottomLeft: SCNVector3, bottomRight: SCNVector3)
}


// Finds 3d vector points for the corners of a rectangle on a plane in a given scene
// Returns 3 corners representing the rectangle as well as the anchor for its plane
//fileprivate func getCorners(for rectangle: VNRectangleObservation, in sceneView: ARSCNView) -> (corners: RectangleCorners, anchor: ARPlaneAnchor)? {
fileprivate func getCorners(for rectangle: VNRectangleObservation, in sceneView: ARSCNView) -> RectangleCorners? {

    // Perform a hittest on each corner to find intersecting surfaces
//    let tl = sceneView.hitTest(sceneView.convertFromCamera(rectangle.topLeft), types: .existingPlaneUsingExtent)
//    let tr = sceneView.hitTest(sceneView.convertFromCamera(rectangle.topRight), types: .existingPlaneUsingExtent)
//    let bl = sceneView.hitTest(sceneView.convertFromCamera(rectangle.bottomLeft), types: .existingPlaneUsingExtent)
//    let br = sceneView.hitTest(sceneView.convertFromCamera(rectangle.bottomRight), types: .existingPlaneUsingExtent)
    
    // MARK:- Andrew's Code
    let tl = sceneView.hitTest(sceneView.convertFromCamera(rectangle.topLeft), types: .featurePoint)
    let tr = sceneView.hitTest(sceneView.convertFromCamera(rectangle.topRight), types: .featurePoint)
    let bl = sceneView.hitTest(sceneView.convertFromCamera(rectangle.bottomLeft), types: .featurePoint)
    let br = sceneView.hitTest(sceneView.convertFromCamera(rectangle.bottomRight), types: .featurePoint)
    
    
    print("--------------------------------------in getCorners()-------------------------------------------")
    // Check top & left corners
    let tlCorners = checkCorners(for: [tl, tr, bl], compareTo: [rectangle.topLeft, rectangle.topRight, rectangle.bottomLeft], in: sceneView)
    if tlCorners.count != 0 {
        print("--------------------------------------FOUND TL CRONERS-------------------------------------------")
        return .topLeft(topLeft: tlCorners[0].worldVector,
                 topRight: tlCorners[1].worldVector,
                 bottomLeft: tlCorners[2].worldVector)
    }
    
    // Check top & right corners
    let trCorners = checkCorners(for: [tl, tr, br], compareTo: [rectangle.topLeft, rectangle.topRight, rectangle.bottomRight], in: sceneView)
    if trCorners.count != 0 {
        print("--------------------------------------FOUND TR CRONERS-------------------------------------------")
        return .topRight(topLeft: trCorners[0].worldVector,
                         topRight: trCorners[1].worldVector,
                         bottomRight: trCorners[2].worldVector)
    }
    
    // Check bottom & left corners
    let blCorners = checkCorners(for: [tl, bl, br], compareTo: [rectangle.topLeft, rectangle.bottomLeft, rectangle.bottomRight], in: sceneView)
    if blCorners.count != 0 {
        print("--------------------------------------FOUND BL CRONERS-------------------------------------------")
        return .bottomLeft(topLeft: blCorners[0].worldVector,
                         bottomLeft: blCorners[1].worldVector,
                         bottomRight: blCorners[2].worldVector)
    }
        
    // Check bottom & right corners
    let brCorners = checkCorners(for: [tr, bl, br], compareTo: [rectangle.topRight, rectangle.bottomLeft, rectangle.bottomRight], in: sceneView)
    if brCorners.count != 0 {
        print("--------------------------------------FOUND BR CRONERS-------------------------------------------")
        return .bottomRight(topRight: brCorners[0].worldVector,
                           bottomLeft: brCorners[1].worldVector,
                           bottomRight: brCorners[2].worldVector)
    }
    
    
    // --------- Andrew's Code End ------------
    
    
    // Not all 4 corners will necessarily be found on the same plane,
    // but we only need 3 corners to define a rectangle.
    // For a set of 3 corners, we will filter out hitResults that don't
    // have a common anchor with all 3 corners and use the closest anchor.
    // For this, we'll need a comparator that returns true if two HitResults use the same anchor
//    let hitResultAnchorComparator: (ARHitTestResult, ARHitTestResult) -> Bool = { (hit1, hit2) in
//        hit1.anchor == hit2.anchor
//    }
//
//
//    // Check top & left corners for a common anchor
//    var surfaces = filterByIntersection([tl, tr, bl], where: hitResultAnchorComparator)
//    if let tlHit = surfaces[0].first,
//        let trHit = surfaces[1].first,
//        let blHit = surfaces[2].first,
//        let anchor = tlHit.anchor as? ARPlaneAnchor {
//
//        print("Found top left corners: \(tlHit.worldVector), \(trHit.worldVector), \(blHit.worldVector)")
//
//        return (.topLeft(topLeft: tlHit.worldVector,
//                         topRight: trHit.worldVector,
//                         bottomLeft: blHit.worldVector),
//                anchor)
//    }
//
//    // Check top & right corners for a common anchor
//    surfaces = filterByIntersection([tl, tr, br], where: hitResultAnchorComparator)
//    if let tlHit = surfaces[0].first,
//        let trHit = surfaces[1].first,
//        let brHit = surfaces[2].first,
//        let anchor = tlHit.anchor as? ARPlaneAnchor {
//
//        print("Found top right corners: \(tlHit.worldVector), \(trHit.worldVector), \(brHit.worldVector)")
//
//        return (.topRight(topLeft: tlHit.worldVector,
//                          topRight: trHit.worldVector,
//                          bottomRight: brHit.worldVector),
//                anchor)
//    }
//
//    // Check bottom & left corners for a common anchor
//    surfaces = filterByIntersection([tl, bl, br], where: hitResultAnchorComparator)
//    if let tlHit = surfaces[0].first,
//        let blHit = surfaces[1].first,
//        let brHit = surfaces[2].first,
//        let anchor = tlHit.anchor as? ARPlaneAnchor {
//
//        print("Found bottom left corners: \(tlHit.worldVector), \(blHit.worldVector), \(brHit.worldVector)")
//
//        return (.bottomLeft(topLeft: tlHit.worldVector,
//                            bottomLeft: blHit.worldVector,
//                            bottomRight: brHit.worldVector),
//                anchor)
//    }
//
//    // Check bottom & right corners for a common anchor
//    surfaces = filterByIntersection([tr, bl, br], where: hitResultAnchorComparator)
//    if let trHit = surfaces[0].first,
//        let blHit = surfaces[1].first,
//        let brHit = surfaces[2].first,
//        let anchor = trHit.anchor as? ARPlaneAnchor {
//
//        print("Found bottom right corners: \(trHit.worldVector), \(blHit.worldVector), \(brHit.worldVector)")
//
//        return (.bottomRight(topRight: trHit.worldVector,
//                             bottomLeft: blHit.worldVector,
//                             bottomRight: brHit.worldVector),
//                anchor)
//    }
//
//    // No set of 3 points have a common anchor, so a rectangle cannot be found on a plane
//    return nil
    return nil
}

extension RectangleCorners {
    
    // Returns width based on left and right corners for one either top or bottom side
    var width: CGFloat {
        get {
            switch self {
            case .topLeft(let left, let right, _),
                 .topRight(let left, let right, _),
                 .bottomLeft(_, let left, let right),
                 .bottomRight(_, let left, let right):
                return right.distance(from: left)
            }
        }
    }
    
    // Returns height based on top and bottom corners for either left or right side
    var height: CGFloat {
        get {
            switch self {
            case .topLeft(let top, _, let bottom),
                 .topRight(_, let top, let bottom),
                 .bottomLeft(let top, let bottom, _),
                 .bottomRight(let top, _, let bottom):
                return top.distance(from: bottom)
            }
        }
    }
    
    // Returns the midpoint from opposite corners of rectangle
    var center: SCNVector3 {
        get {
            switch self {
            case .topLeft(_, let c1, let c2),
                 .topRight(let c1, _, let c2),
                 .bottomRight(let c1, let c2, _),
                 .bottomLeft(let c1, _, let c2):
                return c1.midpoint(from: c2)
            }
        }
    }
    
    // Returns the angle of the vertex corner
    var cornerAngle: CGFloat {
        get {
            switch self {
            // c is the vertex and a & b are the points of the other corners
            case .topLeft(let c, let a, let b),
                 .topRight(let a, let c, let b),
                 .bottomLeft(let a, let c, let b),
                 .bottomRight(let a, let b, let c):
                
                let distA = c.distance(from: b)
                let distB = c.distance(from: a)
                let distC = a.distance(from: b)
                
                
                let cosC = ((distA * distA) + (distB * distB) - (distC * distC)) / (2 * distA * distB)
                return acos(cosC)
            }
        }
    }
    
    // Returns the normal vector
    var normalVector: SCNVector3 {
        get {
            switch self {
            // c is the vertex and a & b are the points of the other corners
            case .topLeft(let c, let a, let b),
                 .topRight(let a, let c, let b),
                 .bottomLeft(let a, let c, let b),
                 .bottomRight(let a, let b, let c):
                
                let ac = SCNVector3.init(c.x-a.x, c.y-a.y, c.z-a.z)
                let bc = SCNVector3.init(c.x-b.x, c.y-b.y, c.z-a.z)
                
                return ac.cross(vector: bc).normalized
            }
        }
    }
    
    
    // Returns the orientation of the rectangle based on how much the rectangle is rotated around the y axis
    var orientation: Float {
        get {
//            switch self {
//            case .topLeft(let left, let right, _),
//                 .topRight(let left, let right, _),
//                 .bottomLeft(_, let left, let right),
//                 .bottomRight(_, let left, let right):
//
//                let distX = right.x - left.x
//                let distZ = right.z - left.z
//                return -atan(distZ / distX)
//            }
            let z = SCNVector3(0.0,0.0,-1.0)
            let xzProj = SCNVector3(normalVector.x, 0.0, normalVector.z).normalized
            let angle = z.angleBetweenVectors(xzProj)
            return Float(angle)
        }
    }
}
