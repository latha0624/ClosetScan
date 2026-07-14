import Foundation
import Combine
import RoomPlan
import ARKit

/// Shared app state across scan, results, and validation flows.
@MainActor
final class AppModel: ObservableObject {
    enum Phase: Equatable {
        case home
        case scanning
        case results
        case validation
    }

    @Published var phase: Phase = .home
    @Published var capturedRoom: CapturedRoom?
    @Published var dimensions: ClosetDimensions?
    @Published var showContents: Bool = false
    @Published var scanErrorMessage: String?
    @Published var deviceSupportsRoomPlan: Bool = false
    /// Increments on every successful scan so the 3D viewer rebuilds.
    @Published var scanGeneration: Int = 0

    let validationStore = ValidationStore()

    init() {
        // RoomPlan needs LiDAR scene reconstruction.
        deviceSupportsRoomPlan = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }

    func beginScan() {
        guard deviceSupportsRoomPlan else {
            scanErrorMessage = "RoomPlan requires a LiDAR-equipped iPhone or iPad Pro (12 Pro or later)."
            return
        }
        scanErrorMessage = nil
        capturedRoom = nil
        dimensions = nil
        showContents = false
        phase = .scanning
    }

    func handleScanComplete(_ room: CapturedRoom) {
        capturedRoom = room
        dimensions = ClosetDimensions.from(capturedRoom: room)
        showContents = false
        scanGeneration += 1
        phase = .results
    }

    func handleScanCancelled() {
        phase = .home
    }

    func handleScanFailed(_ message: String) {
        scanErrorMessage = message
        phase = .home
    }

    func goHome() {
        phase = .home
    }

    func openValidation() {
        phase = .validation
    }

    func backToResults() {
        phase = .results
    }
}
