#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

#if canImport(Glibc)
import Glibc
#elseif os(Windows)
import ucrt
#endif

/// A 2D point represented by x and y coordinates
public struct Point {
    /// The x coordinate
    public let x: Double
    
    /// The y coordinate
    public let y: Double
    
    /// Creates a new point with the given coordinates
    /// - Parameters:
    ///   - x: The x coordinate
    ///   - y: The y coordinate
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

/// A polygon consisting of an outer ring and optional holes
public struct Polygon {
    /// The outer ring of the polygon
    public let outerRing: [Point]
    
    /// Optional holes in the polygon
    public let holes: [[Point]]
    
    /// Creates a new polygon with an outer ring and optional holes
    /// - Parameters:
    ///   - outerRing: The points defining the outer boundary of the polygon
    ///   - holes: An array of point arrays defining holes in the polygon (if any)
    public init(outerRing: [Point], holes: [[Point]] = []) {
        self.outerRing = outerRing
        self.holes = holes
    }
    
    /// Triangulates this polygon using the Earcut algorithm
    /// - Returns: An array of triangle indices referring to points in the flattened data array
    public func triangulate() -> [Int] {
        // Convert polygon structure to flat data array with hole indices
        var data: [Double] = []
        var holeIndices: [Int] = []
        
        // Add outer ring points
        for point in outerRing {
            data.append(point.x)
            data.append(point.y)
        }
        
        // Process holes, adding hole indices
        for hole in holes {
            holeIndices.append(data.count / 2)
            for point in hole {
                data.append(point.x)
                data.append(point.y)
            }
        }
        
        // Triangulate using Earcut algorithm
        return Earcut.triangulate(data, holeIndices: holeIndices)
    }
    
    /// Retrieves all triangles formed by the triangulation
    /// - Returns: Array of triangles, each represented by three points
    public func triangles() -> [[Point]] {
        let indices = triangulate()
        var result: [[Point]] = []
        
        // Collect all points in a flat array
        var allPoints: [Point] = []
        allPoints.append(contentsOf: outerRing)
        for hole in holes {
            allPoints.append(contentsOf: hole)
        }
        
        // Create triangles from indices
        for i in stride(from: 0, to: indices.count, by: 3) {
            if i + 2 < indices.count {
                let triangle = [
                    allPoints[indices[i]],
                    allPoints[indices[i+1]],
                    allPoints[indices[i+2]]
                ]
                result.append(triangle)
            }
        }
        
        return result
    }
    
    /// Computes the area of the polygon
    /// - Returns: The area of the polygon (negative if clockwise, positive if counter-clockwise)
    public func area() -> Double {
        var sum = 0.0
        
        // Calculate area of outer ring
        for i in 0..<outerRing.count {
            let j = (i + 1) % outerRing.count
            sum += outerRing[i].x * outerRing[j].y - outerRing[j].x * outerRing[i].y
        }
        
        // Subtract area of each hole
        for hole in holes {
            for i in 0..<hole.count {
                let j = (i + 1) % hole.count
                sum -= hole[i].x * hole[j].y - hole[j].x * hole[i].y
            }
        }
        
        return sum / 2.0
    }
}