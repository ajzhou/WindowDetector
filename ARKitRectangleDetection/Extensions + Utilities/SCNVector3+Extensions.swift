//
//  SCNVector3+Extensions.swift
//  ARKitRectangleDetection
//
//  Created by Melissa Ludowise on 8/3/17.
//  Copyright © 2017 Mel Ludowise. All rights reserved.
//

import ARKit

extension SCNVector3 {
    
    // Calculate the magnitude of this vector
    var magnitude:SCNFloat {
        get {
            return sqrt(dotProduct(self))
        }
    }
    
    // Vector in the same direction as this vector with a magnitude of 1
    var normalized:SCNVector3 {
        get {
            let localMagnitude = magnitude
            let localX = x / localMagnitude
            let localY = y / localMagnitude
            let localZ = z / localMagnitude
            
            return SCNVector3(localX, localY, localZ)
        }
    }
    func distance(from vector: SCNVector3) -> CGFloat {
        let deltaX = self.x - vector.x
        let deltaY = self.y - vector.y
        let deltaZ = self.z - vector.z
        
        return CGFloat(sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ))
    }
    
    func midpoint(from vector: SCNVector3) -> SCNVector3 {
        let midX = (self.x + vector.x) / 2
        let midY = (self.y + vector.y) / 2
        let midZ = (self.z + vector.z) / 2
        return SCNVector3Make(midX, midY, midZ)
    }
    
    func cross(vector: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(y * vector.z - z * vector.y, z * vector.x - x * vector.z, x * vector.y - y * vector.x)
    }
    
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    func dotProduct(_ vectorB:SCNVector3) -> SCNFloat {
        
        return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
    }
    
    func angleBetweenVectors(_ vectorB:SCNVector3) -> SCNFloat {
        
        //cos(angle) = (A.B)/(|A||B|)
        let cosineAngle = (dotProduct(vectorB) / (magnitude * vectorB.magnitude))
        return SCNFloat(acos(cosineAngle))
    }
    
    func midVector(_ vectorB:SCNVector3) -> SCNVector3 {
        return SCNVector3.init((x + vectorB.x)/2.0, (y + vectorB.y)/2.0, (z + vectorB.z)/2.0)
    }
    
    // from Apples demo APP
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}
