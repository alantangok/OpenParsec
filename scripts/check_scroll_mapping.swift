import Foundation

@main
struct CheckScrollMapping {
	static func expect(_ actual: Int32, _ expected: Int32, _ label: String) {
		if actual != expected {
			fatalError("\(label): expected \(expected), got \(actual)")
		}
	}

	static func expect(_ actual: Bool, _ expected: Bool, _ label: String) {
		if actual != expected {
			fatalError("\(label): expected \(expected), got \(actual)")
		}
	}

	static func main() {
		expect(ScrollWheelMapper.wheelUnits(rawDelta: 40, sensitivity: 1, naturalScrolling: true), -2, "natural downward")
		expect(ScrollWheelMapper.wheelUnits(rawDelta: -40, sensitivity: 1, naturalScrolling: true), 2, "natural upward")
		expect(ScrollWheelMapper.wheelUnits(rawDelta: 40, sensitivity: 1, naturalScrolling: false), 2, "inverted downward")
		expect(ScrollWheelMapper.wheelUnits(rawDelta: 40, sensitivity: 2, naturalScrolling: true), -4, "sensitivity")
		expect(GCMouseScrollMapper.yAxisWheel(rawValue: -1.19, naturalScrolling: true).x, 1, "gcmouse y natural x")
		expect(GCMouseScrollMapper.yAxisWheel(rawValue: -1.19, naturalScrolling: true).y, 0, "gcmouse y natural y")
		expect(GCMouseScrollMapper.yAxisWheel(rawValue: -1.19, naturalScrolling: false).x, -1, "gcmouse y inverted x")
		expect(GCMouseScrollMapper.xAxisWheel(rawValue: 1.19, naturalScrolling: true).x, 0, "gcmouse x natural x")
		expect(GCMouseScrollMapper.xAxisWheel(rawValue: 1.19, naturalScrolling: true).y, -1, "gcmouse x natural y")
		expect(GCMouseScrollMapper.xAxisWheel(rawValue: 1.19, naturalScrolling: false).y, 1, "gcmouse x inverted y")

		ScrollInputGate.reset()
		expect(ScrollInputGate.shouldSendTrackpadScroll(at: 1.0), true, "trackpad initially allowed")
		ScrollInputGate.recordGCMouseScroll(at: 1.0)
		expect(ScrollInputGate.shouldSendTrackpadScroll(at: 1.05), false, "trackpad suppressed after gcmouse")
		expect(ScrollInputGate.shouldSendTrackpadScroll(at: 1.30), true, "trackpad allowed after suppression")

		print("scroll mapping ok")
	}
}
