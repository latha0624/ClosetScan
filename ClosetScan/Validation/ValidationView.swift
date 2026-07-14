import SwiftUI

struct ValidationView: View {
    @EnvironmentObject private var appModel: AppModel

    @State private var tapeWidth = ""
    @State private var tapeDepth = ""
    @State private var tapeHeight = ""
    @State private var lastTrial: ValidationTrial?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Enter tape-measure values in decimal inches (e.g. 48.1875 for 48 3/16\"). Compare against the RoomPlan-derived dimensions.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let dims = appModel.dimensions {
                    Section("App measurement") {
                        LabeledContent("Width", value: dims.widthDisplay)
                        LabeledContent("Depth", value: dims.depthDisplay)
                        LabeledContent("Height", value: dims.heightDisplay)
                    }

                    Section("Tape measure (inches)") {
                        TextField("Width", text: $tapeWidth)
                            .keyboardType(.decimalPad)
                        TextField("Depth", text: $tapeDepth)
                            .keyboardType(.decimalPad)
                        TextField("Height", text: $tapeHeight)
                            .keyboardType(.decimalPad)
                    }

                    Section {
                        Button("Compute error") {
                            saveTrial(using: dims)
                        }
                        .disabled(!canSave)
                    }

                    if let trial = lastTrial {
                        Section("Latest error") {
                            ErrorRow(label: "Width", error: trial.widthError)
                            ErrorRow(label: "Depth", error: trial.depthError)
                            ErrorRow(label: "Height", error: trial.heightError)
                            LabeledContent("Max |error|", value: FractionalInch.formatError(trial.maxAbsErrorInches))
                            LabeledContent(
                                "Within 1/16\"?",
                                value: trial.meetsSixteenthTarget ? "Yes" : "No"
                            )
                            .foregroundStyle(trial.meetsSixteenthTarget ? Color.green : Color.orange)
                        }
                    }
                } else {
                    Section {
                        Text("No scan available. Scan a closet first.")
                    }
                }

                Section("Trial history") {
                    if appModel.validationStore.trials.isEmpty {
                        Text("No trials yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appModel.validationStore.trials) { trial in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(trial.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Max |Δ| \(FractionalInch.formatError(trial.maxAbsErrorInches))")
                                    .font(.subheadline.weight(.semibold))
                                Text(trial.meetsSixteenthTarget ? "Met 1/16\" target" : "Outside 1/16\" target")
                                    .font(.caption)
                                    .foregroundStyle(trial.meetsSixteenthTarget ? .green : .orange)
                            }
                        }
                        Button("Clear history", role: .destructive) {
                            appModel.validationStore.clear()
                            lastTrial = nil
                        }
                    }
                }

                Section("Methodology notes") {
                    Text("""
                    Protocol: measure the same three axes with a steel tape after each scan. Record app vs tape. Repeat ≥3 trials. Report mean absolute error and max absolute error in inches and sixteenths.

                    Honest limit: RoomPlan + LiDAR is typically centimeter-class. Fractional-inch display (1/16\") is the reporting resolution; meeting ≤1/16\" on every axis depends on scan quality, closet geometry, and occlusion.
                    """)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Validation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { appModel.backToResults() }
                }
            }
        }
    }

    private var canSave: Bool {
        parse(tapeWidth) != nil && parse(tapeDepth) != nil && parse(tapeHeight) != nil
    }

    private func parse(_ text: String) -> Double? {
        Double(text.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func saveTrial(using dims: ClosetDimensions) {
        guard let w = parse(tapeWidth), let d = parse(tapeDepth), let h = parse(tapeHeight) else { return }
        let trial = ValidationTrial(
            id: UUID(),
            date: Date(),
            appWidthInches: dims.widthInches,
            appDepthInches: dims.depthInches,
            appHeightInches: dims.heightInches,
            tapeWidthInches: w,
            tapeDepthInches: d,
            tapeHeightInches: h
        )
        appModel.validationStore.add(trial)
        lastTrial = trial
    }
}

private struct ErrorRow: View {
    let label: String
    let error: Double

    var body: some View {
        LabeledContent(label, value: signedError(error))
    }

    private func signedError(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : "-"
        return "\(sign)\(FractionalInch.formatError(value))"
    }
}
