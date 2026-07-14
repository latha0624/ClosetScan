import Foundation
import RoomPlan
import Combine

/// Bridges RoomPlan capture session lifecycle into SwiftUI.
@MainActor
final class RoomCaptureController: NSObject, ObservableObject {
    enum Status: Equatable {
        case idle
        case capturing
        case processing
        case completed
        case failed(String)
        case cancelled
    }

    @Published var status: Status = .idle

    let captureView: RoomCaptureView
    private var isCaptureActive = false

    override init() {
        let view = RoomCaptureView(frame: .zero)
        captureView = view
        super.init()
        view.delegate = self
    }

    func start() {
        let config = RoomCaptureSession.Configuration()
        captureView.captureSession.run(configuration: config)
        isCaptureActive = true
        status = .capturing
    }

    func stop() {
        guard isCaptureActive else { return }
        captureView.captureSession.stop()
        isCaptureActive = false
        status = .processing
    }

    func cancel() {
        if isCaptureActive {
            captureView.captureSession.stop()
            isCaptureActive = false
        }
        status = .cancelled
    }
}

extension RoomCaptureController: RoomCaptureViewDelegate {
    nonisolated func captureView(
        didPresent processedResult: CapturedRoom,
        error: (any Error)?
    ) {
        Task { @MainActor in
            if let error {
                status = .failed(error.localizedDescription)
                return
            }
            status = .completed
            NotificationCenter.default.post(
                name: .roomCaptureDidFinish,
                object: nil,
                userInfo: ["room": processedResult]
            )
        }
    }
}

extension Notification.Name {
    static let roomCaptureDidFinish = Notification.Name("roomCaptureDidFinish")
}
