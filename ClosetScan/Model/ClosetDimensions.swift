import Foundation
import RoomPlan
import simd

/// Closet bounding-box dimensions derived from RoomPlan surfaces.
struct ClosetDimensions: Equatable {
    let widthMeters: Float
    let depthMeters: Float
    let heightMeters: Float
    let surfaceCount: Int
    let objectCount: Int
    let averageConfidenceLabel: String

    var widthInches: Double { Self.metersToInches(widthMeters) }
    var depthInches: Double { Self.metersToInches(depthMeters) }
    var heightInches: Double { Self.metersToInches(heightMeters) }

    var widthDisplay: String { FractionalInch.format(widthInches) }
    var depthDisplay: String { FractionalInch.format(depthInches) }
    var heightDisplay: String { FractionalInch.format(heightInches) }

    var volumeCubicFeet: Double {
        let w = widthInches / 12.0
        let d = depthInches / 12.0
        let h = heightInches / 12.0
        return w * d * h
    }

    static func metersToInches(_ meters: Float) -> Double {
        Double(meters) * 39.37007874015748
    }

    /// Builds dimensions from wall/floor/ceiling surfaces (ignores furniture objects).
    static func from(capturedRoom room: CapturedRoom) -> ClosetDimensions {
        var minP = SIMD3<Float>(repeating: .greatestFiniteMagnitude)
        var maxP = SIMD3<Float>(repeating: -.greatestFiniteMagnitude)
        var samples = 0
        var confidenceSum = 0
        var confidenceCount = 0

        // RoomPlan exposes walls/floors/openings (no ceilings array). Height comes from wall extents.
        let surfaces: [CapturedRoom.Surface] =
            room.walls + room.floors + room.doors + room.windows + room.openings

        for surface in surfaces {
            expandBounds(surface: surface, minP: &minP, maxP: &maxP, samples: &samples)
            confidenceSum += confidenceScore(surface.confidence)
            confidenceCount += 1
        }

        // Fallback: if surface sampling failed, use aggregated wall extents.
        if samples == 0 {
            for wall in room.walls {
                let dim = wall.dimensions
                let t = wall.transform
                let center = SIMD3<Float>(t.columns.3.x, t.columns.3.y, t.columns.3.z)
                let half = SIMD3<Float>(dim.x, dim.y, dim.z) * 0.5
                minP = min(minP, center - half)
                maxP = max(maxP, center + half)
                samples += 1
            }
        }

        let extent: SIMD3<Float>
        if samples > 0 {
            extent = maxP - minP
        } else {
            extent = SIMD3<Float>(1.0, 2.0, 1.0)
        }

        // RoomPlan Y is up. Sort X/Z so width >= depth for a stable reading.
        let horizontal = [abs(extent.x), abs(extent.z)].sorted(by: >)
        let width = max(horizontal[0], 0.01)
        let depth = max(horizontal[1], 0.01)
        let height = max(abs(extent.y), 0.01)

        let avgLabel: String
        if confidenceCount == 0 {
            avgLabel = "unknown"
        } else {
            let avg = Double(confidenceSum) / Double(confidenceCount)
            if avg >= 2.5 { avgLabel = "high" }
            else if avg >= 1.5 { avgLabel = "medium" }
            else { avgLabel = "low" }
        }

        return ClosetDimensions(
            widthMeters: width,
            depthMeters: depth,
            heightMeters: height,
            surfaceCount: surfaces.count,
            objectCount: room.objects.count,
            averageConfidenceLabel: avgLabel
        )
    }

    private static func confidenceScore(_ confidence: CapturedRoom.Confidence) -> Int {
        switch confidence {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        @unknown default: return 1
        }
    }

    private static func expandBounds(
        surface: CapturedRoom.Surface,
        minP: inout SIMD3<Float>,
        maxP: inout SIMD3<Float>,
        samples: inout Int
    ) {
        let dim = surface.dimensions
        let transform = surface.transform
        // Surface local extents: typically x = width, y = height for walls.
        let corners: [SIMD3<Float>] = [
            SIMD3(-dim.x / 2, -dim.y / 2, -dim.z / 2),
            SIMD3( dim.x / 2, -dim.y / 2, -dim.z / 2),
            SIMD3(-dim.x / 2,  dim.y / 2, -dim.z / 2),
            SIMD3( dim.x / 2,  dim.y / 2, -dim.z / 2),
            SIMD3(-dim.x / 2, -dim.y / 2,  dim.z / 2),
            SIMD3( dim.x / 2, -dim.y / 2,  dim.z / 2),
            SIMD3(-dim.x / 2,  dim.y / 2,  dim.z / 2),
            SIMD3( dim.x / 2,  dim.y / 2,  dim.z / 2)
        ]

        for local in corners {
            let world = transform * SIMD4<Float>(local.x, local.y, local.z, 1)
            let p = SIMD3<Float>(world.x, world.y, world.z)
            minP = min(minP, p)
            maxP = max(maxP, p)
            samples += 1
        }
    }
}

/// Formats decimal inches as whole + nearest sixteenths (e.g. 48 3/16").
enum FractionalInch {
    static func format(_ inches: Double) -> String {
        let sign = inches < 0 ? "-" : ""
        let absInches = abs(inches)
        var whole = Int(floor(absInches))
        var sixteenths = Int((absInches - Double(whole)) * 16.0 + 0.5)

        if sixteenths == 16 {
            whole += 1
            sixteenths = 0
        }

        if sixteenths == 0 {
            return "\(sign)\(whole)\""
        }

        let reduced = reduceFraction(sixteenths, 16)
        return "\(sign)\(whole) \(reduced.num)/\(reduced.den)\""
    }

    /// Absolute error formatted in inches + sixteenths.
    static func formatError(_ inches: Double) -> String {
        let absErr = abs(inches)
        let sixteenths = absErr * 16.0
        return String(format: "%.4f\" (%.1f/16\")", absErr, sixteenths)
    }

    private static func reduceFraction(_ numerator: Int, _ denominator: Int) -> (num: Int, den: Int) {
        let g = gcd(numerator, denominator)
        return (numerator / g, denominator / g)
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var x = abs(a)
        var y = abs(b)
        while y != 0 {
            let t = x % y
            x = y
            y = t
        }
        return max(x, 1)
    }
}
