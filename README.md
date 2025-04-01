# Earcut

A Swift implementation of the [Earcut](https://github.com/mapbox/earcut) polygon triangulation algorithm. This library efficiently triangulates 2D polygons with holes.

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Swift CI](https://github.com/apache-edge/earcut/actions/workflows/swift.yml/badge.svg)](https://github.com/apache-edge/earcut/actions/workflows/swift.yml)
[![Platforms](https://img.shields.io/badge/platforms-macOS%20|%20iOS%20|%20tvOS%20|%20iPadOS%20|%20visionOS%20|%20Linux%20|%20Windows%20|%20Android-lightgrey.svg)](https://github.com/apache-edge/earcut)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/apache-edge/earcut?include_prereleases&sort=semver)](https://github.com/apache-edge/earcut/releases)

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Advanced Usage](#advanced-usage)
- [Performance Considerations](#performance-considerations)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [Algorithm Details](#algorithm-details)
- [License](#license)

## Features
- Pure Swift implementation
- Cross-platform support (macOS, iOS, tvOS, iPadOS, visionOS, Linux, Windows, Android)
- Efficient with conditional importing (FoundationEssentials when available)
- Fast and robust polygon triangulation
- Support for polygons with holes
- Comprehensive test suite using Swift Testing
- CI integration with GitHub Actions

## Requirements
- Swift 6.0 or later
- macOS 10.15+, iOS 13.0+, tvOS 13.0+, watchOS 6.0+, or Linux with Swift support
- Xcode 15.0+ (for development on Apple platforms)

## Installation

### Swift Package Manager
Add the dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/apache-edge/earcut.git", from: "0.0.1")
]
```

Then add the dependency to your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Earcut", package: "earcut")
        ]
    )
]
```

### Manual Installation
1. Clone the repository:
```bash
git clone https://github.com/apache-edge/earcut.git
```

2. Drag the `Sources/Earcut` folder into your Xcode project.

## Basic Usage

### Flat Array API
```swift
import Earcut

// Create a flat array of coordinates [x0, y0, x1, y1, ...]
let squareData: [Double] = [0, 0, 1, 0, 1, 1, 0, 1]

// Triangulate the polygon
let indices = Earcut.triangulate(squareData)

// Process the resulting triangle indices...
// Each group of 3 indices forms a triangle
```

### Object-Oriented API
```swift
import Earcut

// Create a polygon with an outer ring
let square = Polygon(
    outerRing: [
        Point(x: 0, y: 0),
        Point(x: 1, y: 0),
        Point(x: 1, y: 1),
        Point(x: 0, y: 1)
    ]
)

// Triangulate the polygon
let indices = square.triangulate()

// Get the triangles as an array of point arrays
let triangles = square.triangles()

// Process the resulting triangles...
```

## Advanced Usage

### Polygons with Holes
```swift
import Earcut

// Create a polygon with a hole
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

// Triangulate the polygon
let triangles = polygonWithHole.triangles()

// Calculate the area of the polygon
let area = polygonWithHole.area()
```

## Performance Considerations

### Time Complexity
The Earcut algorithm has a time complexity of O(n log n) where n is the number of vertices.

### Space Complexity
The space complexity is O(n) for storing the vertices and triangulation results.

### Optimization Tips
- For best performance, avoid unnecessary polygon vertices
- Pre-allocate arrays when processing multiple polygons
- Consider simplifying complex polygons for real-time applications

## API Reference

### Core Types
- `Point`: A 2D point with x and y coordinates
- `Polygon`: A polygon with an outer ring and optional holes
- `Earcut`: The main triangulation algorithm implementation

### Key Functions
- `Earcut.triangulate(_:holeIndices:dimensions:)`: Triangulates a flat array of coordinates
- `Polygon.triangulate()`: Triangulates a polygon object
- `Polygon.triangles()`: Returns the triangulation as an array of point arrays
- `Polygon.area()`: Calculates the area of the polygon

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## Algorithm Details

### Overview
Earcut is an efficient algorithm for triangulating polygons with holes. It works by:
1. Processing the polygon vertices in a specific order
2. Creating a linked list of vertices
3. Connecting holes to the outer polygon
4. Triangulating the resulting shape using ear clipping

### Implementation
This Swift implementation is based on the JavaScript reference implementation by [Mapbox](https://github.com/mapbox/earcut).

### Complexity
The algorithm has a time complexity of O(n log n) and a space complexity of O(n).

## License
This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details.

The Apache License 2.0 is a permissive open source license that allows you to:
- Use the code for commercial purposes
- Modify the code and create derivative works
- Distribute the original or modified code
- Use the code privately

The license requires you to:
- Include the license and copyright notice with any distribution
- State changes made to the code if distributed

## Credits
Based on the original [Earcut](https://github.com/mapbox/earcut) JavaScript implementation by Mapbox.