import Foundation
import Combine

struct ValidationTrial: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let appWidthInches: Double
    let appDepthInches: Double
    let appHeightInches: Double
    let tapeWidthInches: Double
    let tapeDepthInches: Double
    let tapeHeightInches: Double

    var widthError: Double { appWidthInches - tapeWidthInches }
    var depthError: Double { appDepthInches - tapeDepthInches }
    var heightError: Double { appHeightInches - tapeHeightInches }

    var maxAbsErrorInches: Double {
        max(abs(widthError), max(abs(depthError), abs(heightError)))
    }

    var meetsSixteenthTarget: Bool {
        maxAbsErrorInches <= (1.0 / 16.0)
    }
}

@MainActor
final class ValidationStore: ObservableObject {
    @Published private(set) var trials: [ValidationTrial] = []

    private let defaultsKey = "closetscan.validation.trials"

    init() {
        load()
    }

    func add(_ trial: ValidationTrial) {
        trials.insert(trial, at: 0)
        save()
    }

    func clear() {
        trials = []
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return }
        if let decoded = try? JSONDecoder().decode([ValidationTrial].self, from: data) {
            trials = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(trials) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}
