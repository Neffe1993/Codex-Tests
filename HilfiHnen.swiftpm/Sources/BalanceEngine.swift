import Foundation
import Combine

final class BalanceEngine: ObservableObject {
    @Published var sliderValues: [Double]
    @Published var leftValue: Double = 0.3
    @Published var rightValue: Double = 0.7
    @Published var isBalanced: Bool = false

    private let config: BalanceConfig

    init(config: BalanceConfig) {
        self.config = config
        self.sliderValues = Array(repeating: 0.4, count: config.sliderCount)
        recalculate()
    }

    func recalculate() {
        guard !sliderValues.isEmpty else { return }

        let half = sliderValues.count / 2
        let leftSliders = Array(sliderValues.prefix(half))
        let rightSliders = Array(sliderValues.suffix(from: half))

        let leftAvg = leftSliders.reduce(0, +) / Double(max(leftSliders.count, 1))
        let rightAvg = rightSliders.reduce(0, +) / Double(max(rightSliders.count, 1))

        leftValue = leftAvg
        rightValue = rightAvg

        let ratio = leftAvg / (leftAvg + rightAvg + 0.001)
        isBalanced = abs(ratio - config.targetRatio) <= config.tolerance
    }

    func calculateStars() -> Int {
        let leftAvg = sliderValues.prefix(sliderValues.count / 2).reduce(0, +) / Double(max(sliderValues.count / 2, 1))
        let rightAvg = sliderValues.suffix(from: sliderValues.count / 2).reduce(0, +) / Double(max(sliderValues.count - sliderValues.count / 2, 1))
        let ratio = leftAvg / (leftAvg + rightAvg + 0.001)
        let diff = abs(ratio - config.targetRatio)

        if diff <= config.tolerance / 3 { return 3 }
        if diff <= config.tolerance * 0.66 { return 2 }
        return 1
    }
}
