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

struct EarcutTests {
    @Test func testSimpleTriangle() throws {
        let data: [Double] = [0, 0, 1, 0, 0, 1]
        let indices = Earcut.triangulate(data)
        
        #expect(indices.count == 3)
        #expect(indices == [0, 1, 2])
    }
    
    @Test func testSquare() throws {
        let data: [Double] = [0, 0, 1, 0, 1, 1, 0, 1]
        let indices = Earcut.triangulate(data)
        
        #expect(indices.count == 6)
        
        // A square should be split into two triangles
        let correctTriangulation1 = [0, 1, 2, 0, 2, 3]
        let correctTriangulation2 = [3, 0, 1, 3, 1, 2]
        
        // Check if our triangulation matches either correct triangulation
        let isValid = indices == correctTriangulation1 || indices == correctTriangulation2
        #expect(isValid)
    }
    
    @Test func testPolygonWithHole() throws {
        // Outer square: [0,0], [1,0], [1,1], [0,1]
        // Inner square (hole): [0.2,0.2], [0.8,0.2], [0.8,0.8], [0.2,0.8]
        let data: [Double] = [
            0, 0, 1, 0, 1, 1, 0, 1,
            0.2, 0.2, 0.8, 0.2, 0.8, 0.8, 0.2, 0.8
        ]
        let holeIndices = [4]
        
        let indices = Earcut.triangulate(data, holeIndices: holeIndices)
        
        // The hole requires a bridge to the outer polygon which adds complexity
        // We'll just verify that triangulation produced a sensible number of triangles
        #expect(indices.count % 3 == 0)
        #expect(indices.count >= 12) // At least 4 triangles (square) + 4 triangles (hole bridges)
    }
    
    @Test func testEmptyData() throws {
        let indices = Earcut.triangulate([])
        #expect(indices.isEmpty)
    }
    
    @Test func testPointStruct() throws {
        let point = Point(x: 1.5, y: 2.5)
        #expect(point.x == 1.5)
        #expect(point.y == 2.5)
    }
    
    @Test func testPolygonStruct() throws {
        let square = Polygon(
            outerRing: [
                Point(x: 0, y: 0),
                Point(x: 1, y: 0),
                Point(x: 1, y: 1),
                Point(x: 0, y: 1)
            ]
        )
        
        let indices = square.triangulate()
        #expect(indices.count == 6)
        
        let triangles = square.triangles()
        #expect(triangles.count == 2)
    }
    
    @Test func testPolygonWithHoleStruct() throws {
        let polygonWithHole = Polygon(
            outerRing: [
                Point(x: 0, y: 0),
                Point(x: 10, y: 0),
                Point(x: 10, y: 10),
                Point(x: 0, y: 10)
            ],
            holes: [
                [
                    Point(x: 2, y: 2),
                    Point(x: 8, y: 2),
                    Point(x: 8, y: 8),
                    Point(x: 2, y: 8)
                ]
            ]
        )
        
        let triangles = polygonWithHole.triangles()
        #expect(!triangles.isEmpty)
        
        // Each triangle should have exactly 3 points
        for triangle in triangles {
            #expect(triangle.count == 3)
        }
    }
    
    @Test func testPolygonArea() throws {
        // Square of side length 1, area should be 1
        let square = Polygon(
            outerRing: [
                Point(x: 0, y: 0),
                Point(x: 1, y: 0),
                Point(x: 1, y: 1),
                Point(x: 0, y: 1)
            ]
        )
        #expect(square.area() == 1.0)
        
        // Square with a square hole - should be the outer area minus the hole area
        let squareWithHole = Polygon(
            outerRing: [
                Point(x: 0, y: 0),
                Point(x: 10, y: 0),
                Point(x: 10, y: 10),
                Point(x: 0, y: 10)
            ],
            holes: [
                [
                    Point(x: 2, y: 2),
                    Point(x: 8, y: 2),
                    Point(x: 8, y: 8),
                    Point(x: 2, y: 8)
                ]
            ]
        )
        
        // Outer square area is 10×10=100, inner hole is 6×6=36, so difference is 64
        #expect(squareWithHole.area() == 64.0)
    }
}