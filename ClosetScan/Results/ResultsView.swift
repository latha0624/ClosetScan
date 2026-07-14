import SwiftUI

struct ResultsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let room = appModel.capturedRoom {
                    EmptyClosetViewer(
                        room: room,
                        showContents: appModel.showContents,
                        scanGeneration: appModel.scanGeneration
                    )
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)
                        .background(Color.black)
                } else {
                    Color.black.frame(height: 320)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        contentsToggle

                        if let dims = appModel.dimensions {
                            DimensionsPanel(dimensions: dims)
                        }

                        Text("Drag on the 3D view to orbit. Toggle contents off for the empty closet shell used in the interview demo.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Button {
                            appModel.openValidation()
                        } label: {
                            Text("Validate Accuracy")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.20, green: 0.72, blue: 0.62))

                        Button("Scan again") {
                            appModel.beginScan()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Closet Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Home") { appModel.goHome() }
                }
            }
        }
    }

    private var contentsToggle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appModel.showContents ? "Contents visible" : "Contents hidden (empty shell)")
                .font(.headline)

            Toggle(isOn: $appModel.showContents) {
                Text(appModel.showContents
                      ? "Showing detected objects (clothes storage, furniture boxes)"
                      : "Digitally removed — only walls, floor, ceiling, openings")
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .tint(Color(red: 0.20, green: 0.72, blue: 0.62))
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct DimensionsPanel: View {
    let dimensions: ClosetDimensions

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Dimensions")
                .font(.headline)

            DimensionRow(label: "Width", fractional: dimensions.widthDisplay, inches: dimensions.widthInches, meters: dimensions.widthMeters)
            DimensionRow(label: "Depth", fractional: dimensions.depthDisplay, inches: dimensions.depthInches, meters: dimensions.depthMeters)
            DimensionRow(label: "Height", fractional: dimensions.heightDisplay, inches: dimensions.heightInches, meters: dimensions.heightMeters)

            Divider()

            HStack {
                Label("Confidence: \(dimensions.averageConfidenceLabel)", systemImage: "checkmark.seal")
                Spacer()
                Text(String(format: "%.1f ft³", dimensions.volumeCubicFeet))
                    .foregroundStyle(.secondary)
            }
            .font(.caption)

            Text("\(dimensions.surfaceCount) surfaces · \(dimensions.objectCount) objects detected")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct DimensionRow: View {
    let label: String
    let fractional: String
    let inches: Double
    let meters: Float

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 56, alignment: .leading)

            Text(fractional)
                .font(.system(size: 28, weight: .semibold, design: .rounded))

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.3f in", inches))
                    .font(.caption.monospacedDigit())
                Text(String(format: "%.4f m", meters))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }
}
