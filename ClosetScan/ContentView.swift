import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Group {
            switch appModel.phase {
            case .home:
                HomeView()
            case .scanning:
                ScanView()
            case .results:
                ResultsView()
            case .validation:
                ValidationView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: appModel.phase)
    }
}

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.12, blue: 0.18),
                    Color(red: 0.12, green: 0.22, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                Spacer(minLength: 24)

                Text("ClosetScan")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Scan a closet with LiDAR, hide its contents, and measure dimensions to the nearest 1/16\".")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(title: "RoomPlan + LiDAR", detail: "Parametric walls, floor, and ceiling")
                    FeatureRow(title: "Digital empty shell", detail: "Toggle contents on or off")
                    FeatureRow(title: "Fractional inches", detail: "Display + validation vs tape measure")
                }
                .padding(.top, 8)

                if let error = appModel.scanErrorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Color.orange)
                        .padding(.top, 4)
                }

                if !appModel.deviceSupportsRoomPlan {
                    Text("This device does not support RoomPlan. Use a LiDAR iPhone/iPad Pro for the live demo.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.yellow)
                }

                Spacer()

                Button {
                    appModel.beginScan()
                } label: {
                    Text("Scan Closet")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.20, green: 0.72, blue: 0.62))
                .disabled(!appModel.deviceSupportsRoomPlan)

                if appModel.capturedRoom != nil {
                    Button("View last scan") {
                        appModel.phase = .results
                    }
                    .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(28)
        }
    }
}

private struct FeatureRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            Text(detail)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppModel())
}
