//
//  Andrew+Extensions.swift
//  ARKitRectangleDetection
//
//  Created by Andrew Jay Zhou on 12/15/17.
//  Copyright © 2017 Mel Ludowise. All rights reserved.
//

import Foundation
import ARKit
import UIKit
import Vision

func convertFromCamera(_ point: CGPoint, view sceneView: ARSCNView) -> CGPoint {
    let orientation = UIApplication.shared.statusBarOrientation
    
    switch orientation {
    case .portrait, .unknown:
        return CGPoint(x: point.y * sceneView.frame.width, y: point.x * sceneView.frame.height)
    case .landscapeLeft:
        return CGPoint(x: (1 - point.x) * sceneView.frame.width, y: point.y * sceneView.frame.height)
    case .landscapeRight:
        return CGPoint(x: point.x * sceneView.frame.width, y: (1 - point.y) * sceneView.frame.height)
    case .portraitUpsideDown:
        return CGPoint(x: (1 - point.y) * sceneView.frame.width, y: (1 - point.x) * sceneView.frame.height)
    }
}

// TODO: Cases other than portrait may be incorrect
func convertFromCamera(_ point: CGPoint, size: CGSize) -> CGPoint {
    let orientation = UIApplication.shared.statusBarOrientation

    switch orientation {
    case .portrait, .unknown:
        return CGPoint(x: point.x * size.width, y: point.y * size.height)
    case .landscapeLeft:
        return CGPoint(x: (1 - point.x) * size.width, y: point.y * size.height)
    case .landscapeRight:
        return CGPoint(x: point.x * size.width, y: (1 - point.y) * size.height)
    case .portraitUpsideDown:
        return CGPoint(x: (1 - point.x) * size.width, y: (1 - point.y) * size.height)
    }
}
func convertFromCamera(_ rect: CGRect, size: CGSize) -> CGRect {
    let orientation = UIApplication.shared.statusBarOrientation
    print(orientation)
    let x, y, w, h: CGFloat

    switch orientation {
    case .portrait, .unknown:
        w = rect.width
        h = rect.height
        x = rect.origin.x
        y = rect.origin.y
    case .landscapeLeft:
        w = rect.height
        h = rect.width
        x = rect.origin.y
        y = 1 - rect.origin.x - h
    case .landscapeRight:
        w = rect.height
        h = rect.width
        x = 1 - rect.origin.y - w
        y = rect.origin.x
    case .portraitUpsideDown:
        w = rect.height
        h = rect.width
        x = 1 - rect.origin.x - w
        y = 1 - rect.origin.y - h
    }

    return CGRect(x: x * size.width, y: y * size.height, width: w * size.width, height: h * size.height)
}

func convertCGPoint(_ point: CGPoint, view sceneView: ARSCNView) -> CGPoint {
    return CGPoint(x: point.y * sceneView.frame.width, y: point.x * sceneView.frame.height)
}

// expand rectangle region for cropped image for more room for CoreML vision request
func expandRect(_ rect: CGRect, extent container: CGRect) -> CGRect {
    // TODO: play with increment ratio to see how it affect vision request results
    let widthIncrement = rect.size.width
    let heighIncrement = rect.size.height

    var x = rect.origin.x - widthIncrement / 2.0
    if x < container.origin.x {
        x = container.origin.x
    }
    
    var width = rect.size.width + widthIncrement
    if (x + width > container.origin.x + container.size.width) {
        width = container.size.width - x
    }
    
    var y = rect.origin.y - heighIncrement / 2.0
    if y < container.origin.y {
        y = container.origin.y
    }
    
    var height = rect.size.height + heighIncrement
    if (y + height > container.origin.y + container.size.height) {
        height = container.size.height - y
    }
    
    return CGRect(x: x, y: y, width: width, height: height)
}

// TODO: optimize and check conversion accuracy
func checkCorners(for hitTestResults: [[ARHitTestResult]], compareTo corners: [CGPoint], in sceneView: ARSCNView) -> [ARHitTestResult]{
    var hit0: ARHitTestResult?
    var hit1: ARHitTestResult?
    var hit2: ARHitTestResult?
    let TOLERANCE: CGFloat = 0.01
    
    var hit0error: CGFloat = 1.0
    for currentResult in hitTestResults[0] {
        let projectPt = sceneView.projectPoint(currentResult.worldVector)
        let projectPt2d = CGPoint(x: CGFloat(projectPt.x), y: CGFloat(projectPt.y)) // TODO: check if conversion like this is accuracte, also z component is ignored
        let original = convertFromCamera(corners[0], view: sceneView)
        
        let error = abs((projectPt2d.x - original.x) / original.x) + abs((projectPt2d.y - original.y) / original.y)
        if error < TOLERANCE && error < hit0error{
            hit0error = error
            hit0 = currentResult
        }
    }
    
    var hit1error: CGFloat = 1.0
    for currentResult in hitTestResults[1] {
        let projectPt = sceneView.projectPoint(currentResult.worldVector)
        let projectPt2d = CGPoint(x: CGFloat(projectPt.x), y: CGFloat(projectPt.y)) // TODO: check if conversion like this is accuracte, also z component is ignored
        let original = convertFromCamera(corners[1], view: sceneView)
        
        let error = abs((projectPt2d.x - original.x) / original.x) + abs((projectPt2d.y - original.y) / original.y)
        if error < TOLERANCE && error < hit1error{
            hit1error = error
            hit1 = currentResult
        }
    }
    
    var hit2error: CGFloat = 1.0
    for currentResult in hitTestResults[2] {
        let projectPt = sceneView.projectPoint(currentResult.worldVector)
        let projectPt2d = CGPoint(x: CGFloat(projectPt.x), y: CGFloat(projectPt.y)) // TODO: check if conversion like this is accuracte, also z component is ignored
        let original = convertFromCamera(corners[2], view: sceneView)
        
        let error = abs((projectPt2d.x - original.x) / original.x) + abs((projectPt2d.y - original.y) / original.y)
        if error < TOLERANCE && error < hit2error{
            hit2error = error
            hit2 = currentResult
        }
    }
    
    if let ret0 = hit0, let ret1 = hit1, let ret2 = hit2 {
        return [ret0, ret1, ret2]
    } else {
        print("no matches found")
        return []
    }
}

