import Foundation
import RoomPlan
import Combine

/// Bridges RoomPlan capture session lifecycle into SwiftUI.
final class RoomCaptureController: ObservableObject {
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
    private let delegateBridge = RoomCaptureDelegateBridge()

    init() {
        captureView = RoomCaptureView(frame: .zero)
        delegateBridge.owner = self
        captureView.delegate = delegateBridge
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

    fileprivate func handlePresent(_ processedResult: CapturedRoom, error: Error?) {
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

/// Stable ObjC-visible RoomPlan delegate (RoomCaptureViewDelegate pulls in NSCoding).
@objc(ClosetScanRoomCaptureDelegateBridge)
final class RoomCaptureDelegateBridge: NSObject, RoomCaptureViewDelegate, NSSecureCoding {
    static var supportsSecureCoding: Bool { true }

    weak var owner: RoomCaptureController?

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init()
    }

    func encode(with coder: NSCoder) {}

    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        true
    }

    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.owner?.handlePresent(processedResult, error: error)
        }
    }
}

extension Notification.Name {
    static let roomCaptureDidFinish = Notification.Name("roomCaptureDidFinish")
}
