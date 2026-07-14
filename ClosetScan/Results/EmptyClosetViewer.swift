import SwiftUI
import RealityKit
import RoomPlan
import simd
import UIKit

/// RealityKit dollhouse of the closet. Surfaces always shown; objects optional.
struct EmptyClosetViewer: UIViewRepresentable {
    let room: CapturedRoom
    let showContents: Bool
    let scanGeneration: Int

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        arView.environment.background = .color(.black)
        context.coordinator.arView = arView
        context.coordinator.rebuild(room: room, showContents: showContents, scanGeneration: scanGeneration)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.rebuild(room: room, showContents: showContents, scanGeneration: scanGeneration)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        weak var arView: ARView?
        private var rootEntity: ModelEntity?
        private var lastShowContents: Bool?
        private var lastScanGeneration: Int = -1

        func rebuild(room: CapturedRoom, showContents: Bool, scanGeneration: Int) {
            guard let arView else { return }

            if lastShowContents == showContents,
               lastScanGeneration == scanGeneration,
               rootEntity != nil {
                return
            }
            lastShowContents = showContents
            lastScanGeneration = scanGeneration

            arView.scene.anchors.removeAll()

            let anchor = AnchorEntity(world: .zero)
            let root = ModelEntity()
            anchor.addChild(root)

            let wallMaterial = SimpleMaterial(
                color: UIColor(red: 0.75, green: 0.82, blue: 0.88, alpha: 0.95),
                roughness: 0.85,
                isMetallic: false
            )
            let floorMaterial = SimpleMaterial(
                color: UIColor(red: 0.45, green: 0.52, blue: 0.48, alpha: 0.95),
                roughness: 0.9,
                isMetallic: false
            )
            let ceilingMaterial = SimpleMaterial(
                color: UIColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 0.55),
                roughness: 0.95,
                isMetallic: false
            )
            let openingMaterial = SimpleMaterial(
                color: UIColor(red: 0.20, green: 0.72, blue: 0.62, alpha: 0.35),
                roughness: 0.5,
                isMetallic: false
            )
            let objectMaterial = SimpleMaterial(
                color: UIColor(red: 0.95, green: 0.55, blue: 0.25, alpha: 0.75),
                roughness: 0.6,
                isMetallic: false
            )

            for wall in room.walls {
                root.addChild(boxEntity(for: wall.dimensions, transform: wall.transform, material: wallMaterial))
            }
            for floor in room.floors {
                root.addChild(boxEntity(for: floor.dimensions, transform: floor.transform, material: floorMaterial))
            }
            for ceiling in room.ceilings {
                root.addChild(boxEntity(for: ceiling.dimensions, transform: ceiling.transform, material: ceilingMaterial))
            }
            for door in room.doors {
                root.addChild(boxEntity(for: door.dimensions, transform: door.transform, material: openingMaterial))
            }
            for window in room.windows {
                root.addChild(boxEntity(for: window.dimensions, transform: window.transform, material: openingMaterial))
            }
            for opening in room.openings {
                root.addChild(boxEntity(for: opening.dimensions, transform: opening.transform, material: openingMaterial))
            }

            if showContents {
                for object in room.objects {
                    root.addChild(boxEntity(for: object.dimensions, transform: object.transform, material: objectMaterial))
                }
            }

            // Fit camera to bounds
            let bounds = root.visualBounds(relativeTo: nil)
            let extent = bounds.extents
            let center = bounds.center
            let radius = max(max(extent.x, extent.y), extent.z)
            let distance = max(radius * 2.4, 1.5)

            let camera = PerspectiveCamera()
            camera.look(
                at: center,
                from: center + SIMD3<Float>(distance * 0.7, distance * 0.45, distance * 0.7),
                relativeTo: nil
            )
            anchor.addChild(camera)

            arView.scene.addAnchor(anchor)
            rootEntity = root

            // Orbit-friendly: install a simple gesture via UIKit
            if arView.gestureRecognizers?.contains(where: { $0 is UIPanGestureRecognizer }) != true {
                let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                arView.addGestureRecognizer(pan)
            }
        }

        private func boxEntity(
            for dimensions: simd_float3,
            transform: simd_float4x4,
            material: SimpleMaterial
        ) -> ModelEntity {
            let size = SIMD3<Float>(
                max(dimensions.x, 0.01),
                max(dimensions.y, 0.01),
                max(max(dimensions.z, 0.01), 0.02)
            )
            let mesh = MeshResource.generateBox(size: size, cornerRadius: 0.005)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.transform.matrix = transform
            return entity
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let arView, let rootEntity else { return }
            let translation = gesture.translation(in: arView)
            let yaw = Float(translation.x) * 0.005
            let pitch = Float(translation.y) * 0.003
            rootEntity.orientation = simd_mul(
                simd_quatf(angle: yaw, axis: [0, 1, 0]),
                rootEntity.orientation
            )
            rootEntity.orientation = simd_mul(
                simd_quatf(angle: pitch, axis: [1, 0, 0]),
                rootEntity.orientation
            )
            gesture.setTranslation(.zero, in: arView)
        }
    }
}
