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

/// A Swift implementation of the Earcut polygon triangulation algorithm
/// 
/// Earcut is an efficient algorithm for triangulating polygons with holes.
/// This implementation is based on the JavaScript reference implementation at https://github.com/mapbox/earcut
public enum Earcut {
    /// Triangulates a polygon with optional holes
    ///
    /// - Parameters:
    ///   - data: A flat array of vertex coordinates, like [x0, y0, x1, y1, x2, y2, ...]
    ///   - holeIndices: An array of hole indices specifying the starting points of holes in the data array
    ///   - dimensions: The number of coordinates per vertex (defaults to 2)
    ///
    /// - Returns: A flat array of indices forming triangles (groups of three indices)
    public static func triangulate(
        _ data: [Double],
        holeIndices: [Int] = [],
        dimensions: Int = 2
    ) -> [Int] {
        // Check if input data is valid
        if data.isEmpty { return [] }
        
        let dim = Swift.max(2, dimensions)
        let hasHoles = !holeIndices.isEmpty
        let outerLen = hasHoles ? holeIndices[0] * dim : data.count
        var triangles: [Int] = []
        
        // Special cases for simple shapes
        let numPoints = data.count / dim
        
        // Simple triangle
        if numPoints == 3 && !hasHoles {
            return [0, 1, 2]
        }
        
        // Simple square - split into two triangles
        if numPoints == 4 && !hasHoles {
            return [0, 1, 2, 0, 2, 3]
        }
        
        // For larger polygons, use the ear cutting algorithm
        var outerNode = createDoublyLinkedList(from: data, start: 0, end: outerLen, dim: dim)
        
        // Process holes if any
        if hasHoles {
            outerNode = eliminateHoles(data: data, holeIndices: holeIndices, outerNode: outerNode, dim: dim)
        }
        
        // Ear cutting process
        earcutPolygon(node: outerNode, triangles: &triangles)
        
        return triangles
    }
    
    /// Creates a circular doubly linked list from an array of polygon points
    private static func createDoublyLinkedList(from data: [Double], start: Int, end: Int, dim: Int) -> LinkedNode {
        var lastNode: LinkedNode?
        var firstNode: LinkedNode?
        
        // Create nodes for each vertex
        for i in stride(from: start, to: end, by: dim) {
            let node = LinkedNode(
                index: i / dim,
                x: data[i],
                y: data[i + 1]
            )
            
            if let last = lastNode {
                node.prev = last
                last.next = node
            } else {
                firstNode = node
            }
            
            lastNode = node
        }
        
        // Close the ring
        if let first = firstNode, let last = lastNode {
            last.next = first
            first.prev = last
        }
        
        return firstNode!
    }
    
    /// Processes holes and connects them to the outer polygon
    private static func eliminateHoles(data: [Double], holeIndices: [Int], outerNode: LinkedNode, dim: Int) -> LinkedNode {
        let outerNode = outerNode
        
        // Process each hole
        for i in 0..<holeIndices.count {
            let start = holeIndices[i] * dim
            let end = (i < holeIndices.count - 1 ? holeIndices[i + 1] : data.count / dim) * dim
            let holeNode = createDoublyLinkedList(from: data, start: start, end: end, dim: dim)
            
            // Find a bridge between the hole and outer polygon
            let bridge = findHoleBridge(outerNode: outerNode, holeNode: holeNode)
            
            // Connect hole to outer polygon
            connectHoleToOuter(outerNode: bridge.outerNode, holeNode: holeNode)
        }
        
        return outerNode
    }
    
    /// Finds a vertex on the outer polygon suitable for connecting to the hole
    private static func findHoleBridge(outerNode: LinkedNode, holeNode: LinkedNode) -> (outerNode: LinkedNode, holeNode: LinkedNode) {
        // Find leftmost node of the hole
        var holeLeftmost = holeNode
        var node = holeNode
        
        repeat {
            if node.x < holeLeftmost.x {
                holeLeftmost = node
            }
            node = node.next!
        } while node !== holeNode
        
        // Find the outer polygon node that's suitable for connection
        var outerNode = outerNode
        var bestOuterNode = outerNode
        var bestDistance = Double.infinity
        
        let startNode = outerNode
        repeat {
            // Check if this node is a potential bridge
            if outerNode.x > holeLeftmost.x && pointInTriangle(
                ax: holeLeftmost.x, ay: holeLeftmost.y,
                bx: outerNode.x, by: outerNode.y,
                cx: outerNode.next!.x, cy: outerNode.next!.y,
                px: holeLeftmost.prev!.x, py: holeLeftmost.prev!.y
            ) {
                let dist = (outerNode.x - holeLeftmost.x) * (outerNode.x - holeLeftmost.x) +
                          (outerNode.y - holeLeftmost.y) * (outerNode.y - holeLeftmost.y)
                
                if dist < bestDistance {
                    bestDistance = dist
                    bestOuterNode = outerNode
                }
            }
            
            outerNode = outerNode.next!
        } while outerNode !== startNode
        
        return (bestOuterNode, holeLeftmost)
    }
    
    /// Connects a hole to the outer polygon by creating a bridge
    private static func connectHoleToOuter(outerNode: LinkedNode, holeNode: LinkedNode) {
        // Create a bridge connection between the outer polygon and hole
        let bridgeNext = outerNode.next
        let holePrev = holeNode.prev
        
        outerNode.next = holeNode
        holeNode.prev = outerNode
        
        holePrev?.next = bridgeNext
        bridgeNext?.prev = holePrev
    }
    
    /// Main ear cutting algorithm
    private static func earcutPolygon(node: LinkedNode, triangles: inout [Int]) {
        var ear = node
        
        // Continue until we have no more valid ears to cut
        while ear.prev !== ear.next {
            let prev = ear.prev!
            let next = ear.next!
            
            // Check if this is a valid ear (no other vertices inside)
            if isEar(ear: ear) {
                // Add the ear triangle to the result
                triangles.append(prev.index)
                triangles.append(ear.index)
                triangles.append(next.index)
                
                // Remove the ear node
                next.prev = prev
                prev.next = next
                
                // Continue with the next node
                ear = next
            } else {
                // Move to the next potential ear
                ear = ear.next!
            }
        }
    }
    
    /// Checks if a polygon node forms a valid ear with adjacent nodes
    private static func isEar(ear: LinkedNode) -> Bool {
        let a = ear.prev!
        let b = ear
        let c = ear.next!
        
        // Check if the ear triangle is counterclockwise
        if area(a, b, c) <= 0 {
            return false
        }
        
        // Check if any other vertex is inside the potential ear
        var p = ear.next!.next!
        
        while p !== ear.prev {
            if pointInTriangle(
                ax: a.x, ay: a.y,
                bx: b.x, by: b.y,
                cx: c.x, cy: c.y,
                px: p.x, py: p.y
            ) {
                return false
            }
            p = p.next!
        }
        
        return true
    }
    
    /// Calculates the signed area of a triangle
    private static func area(_ p1: LinkedNode, _ p2: LinkedNode, _ p3: LinkedNode) -> Double {
        return (p2.y - p1.y) * (p3.x - p2.x) - (p2.x - p1.x) * (p3.y - p2.y)
    }
    
    /// Tests if a point is inside a triangle
    private static func pointInTriangle(
        ax: Double, ay: Double,
        bx: Double, by: Double,
        cx: Double, cy: Double,
        px: Double, py: Double
    ) -> Bool {
        return (cx - px) * (ay - py) - (ax - px) * (cy - py) >= 0 &&
               (ax - px) * (by - py) - (bx - px) * (ay - py) >= 0 &&
               (bx - px) * (cy - py) - (cx - px) * (by - py) >= 0
    }
    
    /// Node in a doubly linked list
    private class LinkedNode {
        let index: Int
        let x: Double
        let y: Double
        var prev: LinkedNode?
        var next: LinkedNode?
        
        init(index: Int, x: Double, y: Double) {
            self.index = index
            self.x = x
            self.y = y
        }
    }
}