import SwiftUI
import RoomPlan
import UIKit

struct RoomCaptureViewRepresentable: UIViewRepresentable {
    let captureView: RoomCaptureView

    func makeUIView(context: Context) -> RoomCaptureView {
        captureView
    }

    func updateUIView(_ uiView: RoomCaptureView, context: Context) {}
}

struct ScanView: View {
    @EnvironmentObject private var appModel: AppModel
    @StateObject private var controller = RoomCaptureController()

    var body: some View {
        ZStack(alignment: .bottom) {
            RoomCaptureViewRepresentable(captureView: controller.captureView)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text(statusText)
                    .font(.footnote.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())

                HStack(spacing: 16) {
                    Button("Cancel") {
                        controller.cancel()
                        appModel.handleScanCancelled()
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)

                    Button(primaryButtonTitle) {
                        if controller.status == .capturing {
                            controller.stop()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.20, green: 0.72, blue: 0.62))
                    .disabled(controller.status != .capturing)
                }
            }
            .padding(.bottom, 36)
        }
        .onAppear {
            controller.start()
        }
        .onReceive(NotificationCenter.default.publisher(for: .roomCaptureDidFinish)) { note in
            if let room = note.userInfo?["room"] as? CapturedRoom {
                appModel.handleScanComplete(room)
            }
        }
        .onChange(of: controller.status) { _, newValue in
            if case .failed(let message) = newValue {
                appModel.handleScanFailed(message)
            } else if newValue == .cancelled {
                appModel.handleScanCancelled()
            }
        }
    }

    private var statusText: String {
        switch controller.status {
        case .idle:
            return "Preparing sensors…"
        case .capturing:
            return "Walk slowly around the closet. Cover every wall, then tap Done."
        case .processing:
            return "Building empty shell + dimensions…"
        case .completed:
            return "Scan complete"
        case .failed(let message):
            return message
        case .cancelled:
            return "Cancelled"
        }
    }

    private var primaryButtonTitle: String {
        switch controller.status {
        case .processing:
            return "Processing…"
        default:
            return "Done"
        }
    }
}
