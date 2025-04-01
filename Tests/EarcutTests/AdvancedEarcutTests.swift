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

import Testing
@testable import Earcut

struct AdvancedEarcutTests {
    // Test triangulation of a concave polygon
    @Test func testConcavePolygon() throws {
        // Create a concave polygon (arrow shape)
        let data: [Double] = [
            0, 0,    // 0
            2, 0,    // 1
            2, 1,    // 2
            1, 1,    // 3
            1, 2,    // 4
            0, 1     // 5
        ]
        
        let indices = Earcut.triangulate(data)
        
        // Verify basic properties
        #expect(indices.count % 3 == 0)
        #expect(indices.count >= 12) // Should have at least 4 triangles
        
        // Verify all indices are within bounds
        for index in indices {
            #expect(index >= 0 && index < data.count / 2)
        }
    }
    
    // Test triangulation of a polygon with multiple holes
    @Test func testPolygonWithMultipleHoles() throws {
        // Outer square: [0,0], [10,0], [10,10], [0,10]
        // First hole (square): [1,1], [3,1], [3,3], [1,3]
        // Second hole (square): [6,6], [9,6], [9,9], [6,9]
        let data: [Double] = [
            0, 0, 10, 0, 10, 10, 0, 10,
            1, 1, 3, 1, 3, 3, 1, 3,
            6, 6, 9, 6, 9, 9, 6, 9
        ]
        let holeIndices = [4, 8]
        
        let indices = Earcut.triangulate(data, holeIndices: holeIndices)
        
        // Verify basic properties
        #expect(indices.count % 3 == 0)
        #expect(indices.count >= 24) // Should have at least 8 triangles
        
        // Verify all indices are within bounds
        for index in indices {
            #expect(index >= 0 && index < data.count / 2)
        }
    }
    
    // Test triangulation of a polygon with collinear points
    @Test func testCollinearPoints() throws {
        // Square with an extra collinear point on the top edge
        let data: [Double] = [
            0, 0, 5, 0, 10, 0, 10, 10, 0, 10
        ]
        
        let indices = Earcut.triangulate(data)
        
        // Verify basic properties
        #expect(indices.count % 3 == 0)
        #expect(indices.count >= 9) // Should have at least 3 triangles
        
        // Verify all indices are within bounds
        for index in indices {
            #expect(index >= 0 && index < data.count / 2)
        }
    }
    
    // Test triangulation of a more complex shape
    @Test func testComplexShape() throws {
        // Star-like shape
        let data: [Double] = [
            5, 0,    // 0
            6, 3,    // 1
            9, 4,    // 2
            6, 5,    // 3
            7, 8,    // 4
            5, 6,    // 5
            3, 8,    // 6
            4, 5,    // 7
            1, 4,    // 8
            4, 3     // 9
        ]
        
        let indices = Earcut.triangulate(data)
        
        // Verify basic properties
        #expect(indices.count % 3 == 0)
        #expect(indices.count >= 24) // Should have at least 8 triangles
        
        // Verify all indices are within bounds
        for index in indices {
            #expect(index >= 0 && index < data.count / 2)
        }
    }
    
    // Test validation of triangulation results
    @Test func testTriangulationValidation() throws {
        let square = Polygon(
            outerRing: [
                Point(x: 0, y: 0),
                Point(x: 10, y: 0),
                Point(x: 10, y: 10),
                Point(x: 0, y: 10)
            ]
        )
        
        let triangles = square.triangles()
        
        // Check that all triangles have positive area
        for triangle in triangles {
            let area = triangleArea(triangle[0], triangle[1], triangle[2])
            #expect(area > 0)
        }
        
        // Check that the sum of triangle areas equals the polygon area
        var totalTriangleArea = 0.0
        for triangle in triangles {
            totalTriangleArea += abs(triangleArea(triangle[0], triangle[1], triangle[2]))
        }
        
        let polygonArea = abs(square.area())
        #expect(abs(totalTriangleArea - polygonArea) < 1e-10)
    }
    
    // Helper function to calculate triangle area
    private func triangleArea(_ a: Point, _ b: Point, _ c: Point) -> Double {
        return ((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)) / 2.0
    }
    
    // Performance test for large polygons
    @Test func testLargePolygonPerformance() throws {
        // Create a large polygon with 1000 points
        var data: [Double] = []
        let radius = 100.0
        let count = 1000
        
        for i in 0..<count {
            let angle = 2.0 * Double.pi * Double(i) / Double(count)
            let x = radius * cos(angle)
            let y = radius * sin(angle)
            data.append(x)
            data.append(y)
        }
        
        // Measure triangulation time
        let startTime = Date()
        let indices = Earcut.triangulate(data)
        let endTime = Date()
        
        // Verify triangulation produced the expected number of triangles
        #expect(indices.count == (count - 2) * 3)
        
        // Log performance info (not an actual test assertion)
        let timeElapsed = endTime.timeIntervalSince(startTime)
        print("Triangulation of \(count) points took \(timeElapsed) seconds")
    }
}
