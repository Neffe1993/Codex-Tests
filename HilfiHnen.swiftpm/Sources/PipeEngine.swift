import Foundation
import Combine

struct PipeCell: Identifiable {
    let id: UUID = UUID()
    var row: Int
    var col: Int
    var rotation: Int = 0    // 0,1,2,3 = 0°,90°,180°,270°
    var type: PipeSegment.SegmentType
    var isFixed: Bool

    var openings: Set<Direction> {
        let base = baseOpenings
        let rot = rotation
        return Set(base.map { $0.rotated(times: rot) })
    }

    private var baseOpenings: Set<Direction> {
        switch type {
        case .straight:  return [.top, .bottom]
        case .curve:     return [.top, .right]
        case .junction:  return [.top, .right, .bottom]
        case .end:       return [.top]
        }
    }
}

enum Direction: CaseIterable {
    case top, right, bottom, left

    func rotated(times: Int) -> Direction {
        let all: [Direction] = [.top, .right, .bottom, .left]
        let idx = all.firstIndex(of: self)!
        return all[(idx + times) % 4]
    }

    var opposite: Direction {
        switch self {
        case .top:    return .bottom
        case .right:  return .left
        case .bottom: return .top
        case .left:   return .right
        }
    }

    var delta: (row: Int, col: Int) {
        switch self {
        case .top:    return (-1, 0)
        case .right:  return (0, 1)
        case .bottom: return (1, 0)
        case .left:   return (0, -1)
        }
    }
}

final class PipeEngine: ObservableObject {
    @Published var cells: [PipeCell] = []
    @Published var flowPath: Set<Int> = []
    @Published var coinsCollected: Double = 0.0
    @Published var isConnected: Bool = false

    private let config: PipeConfig
    private var coinTimer: Timer?
    private let gridSize: Int

    init(config: PipeConfig) {
        self.config = config
        self.gridSize = config.gridSize
        buildCells()
        checkFlow()
    }

    private func buildCells() {
        var result: [PipeCell] = []
        for seg in config.segments {
            result.append(PipeCell(row: seg.row, col: seg.col, type: seg.type, isFixed: seg.isFixed))
        }
        // Fill remaining cells with random pipe pieces
        let occupied = Set(config.segments.map { "\($0.row),\($0.col)" })
        let types: [PipeSegment.SegmentType] = [.straight, .curve, .curve, .junction]
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if !occupied.contains("\(row),\(col)") {
                    let type = types.randomElement()!
                    result.append(PipeCell(row: row, col: col, rotation: Int.random(in: 0...3), type: type, isFixed: false))
                }
            }
        }
        cells = result
    }

    func rotate(index: Int) {
        guard !cells[index].isFixed else { return }
        cells[index].rotation = (cells[index].rotation + 1) % 4
        checkFlow()
    }

    private func cellAt(row: Int, col: Int) -> (index: Int, cell: PipeCell)? {
        if let i = cells.firstIndex(where: { $0.row == row && $0.col == col }) {
            return (i, cells[i])
        }
        return nil
    }

    private func checkFlow() {
        guard let startEntry = config.segments.first,
              let endEntry = config.segments.last else { return }

        var visited = Set<Int>()
        var queue: [(row: Int, col: Int)] = [(startEntry.row, startEntry.col)]

        while !queue.isEmpty {
            let current = queue.removeFirst()
            guard let (idx, cell) = cellAt(row: current.row, col: current.col) else { continue }
            if visited.contains(idx) { continue }
            visited.insert(idx)

            for dir in cell.openings {
                let delta = dir.delta
                let nextRow = current.row + delta.row
                let nextCol = current.col + delta.col
                guard nextRow >= 0, nextRow < gridSize, nextCol >= 0, nextCol < gridSize else { continue }
                if let (nextIdx, nextCell) = cellAt(row: nextRow, col: nextCol) {
                    if nextCell.openings.contains(dir.opposite) && !visited.contains(nextIdx) {
                        queue.append((nextRow, nextCol))
                    }
                }
            }
        }

        flowPath = visited
        let endIdx = cells.firstIndex(where: { $0.row == endEntry.row && $0.col == endEntry.col })
        let reached = endIdx.map { visited.contains($0) } ?? false

        if reached && !isConnected {
            isConnected = true
            startCoinFlow()
        } else if !reached && isConnected {
            isConnected = false
            stopCoinFlow()
        }
    }

    private func startCoinFlow() {
        coinTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.coinsCollected = min(self.coinsCollected + 2.0, Double(self.config.coinTarget))
            }
        }
    }

    private func stopCoinFlow() {
        coinTimer?.invalidate()
        coinTimer = nil
    }

    deinit { stopCoinFlow() }
}
