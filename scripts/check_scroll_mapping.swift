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

	static func expectNear(_ actual: Float, _ expected: Float, _ label: String, tolerance: Float = 0.001) {
		if abs(actual - expected) > tolerance {
			fatalError("\(label): expected \(expected), got \(actual)")
		}
	}

	static func main() {
		expect(ScrollWheelMapper.wheelUnits(rawDelta: 40, sensitivity: 1, naturalScrolling: true), -2, "natural downward")
		expect(ScrollWheelMapper.wheelUnits(rawDelta: -40, sensitivity: 1, naturalScrolling: true), 2, "natural upward")
		expect(ScrollWheelMapper.wheelUnits(rawDelta: 40, sensitivity: 1, naturalScrolling: false), 2, "inverted downward")
		expect(ScrollWheelMapper.wheelUnits(rawDelta: 40, sensitivity: 2, naturalScrolling: true), -4, "sensitivity")
		let naturalY = GCMouseScrollMapper.adjustedDelta(axis: .y, rawValue: -1.19, naturalScrolling: true)
		expectNear(naturalY.x, 1.19, "gcmouse y natural x")
		expectNear(naturalY.y, 0, "gcmouse y natural y")
		expectNear(GCMouseScrollMapper.adjustedDelta(axis: .y, rawValue: -1.19, naturalScrolling: false).x, -1.19, "gcmouse y inverted x")
		let naturalX = GCMouseScrollMapper.adjustedDelta(axis: .x, rawValue: 1.19, naturalScrolling: true)
		expectNear(naturalX.x, 0, "gcmouse x natural x")
		expectNear(naturalX.y, -1.19, "gcmouse x natural y")
		expectNear(GCMouseScrollMapper.adjustedDelta(axis: .x, rawValue: 1.19, naturalScrolling: false).y, 1.19, "gcmouse x inverted y")

		var motion = GCMouseScrollMotion()
		var accumulatedX: Int32 = 0
		for index in 0..<8 {
			let wheel = motion.consume(axis: .y, rawValue: -0.25, naturalScrolling: true, at: Double(index) * 0.02)
			accumulatedX += wheel.x
		}
		expect(accumulatedX, 2, "gcmouse fractional deltas accumulate")
		expectNear(motion.velocityX, 12.47952, "gcmouse velocity smoothing")
		expect(motion.shouldStartMomentum(minimumSpeed: 10), true, "gcmouse momentum starts")
		var momentumX: Int32 = 0
		for _ in 0..<30 {
			momentumX += motion.momentumWheel(deltaTime: 1.0 / 60.0, decayPerSecond: 0.004).x
		}
		expect(momentumX > 0, true, "gcmouse momentum emits decaying wheel units")
		expect(motion.shouldStopMomentum(maximumSpeed: 2), true, "gcmouse momentum stops after decay")

		motion.reset()
		for index in 0..<3 {
			_ = motion.consume(axis: .y, rawValue: -0.25, naturalScrolling: true, at: Double(index) * 0.02)
		}
		motion.reset()
		let afterReset = motion.consume(axis: .y, rawValue: -0.25, naturalScrolling: true, at: 1.0)
		expect(afterReset.x, 0, "gcmouse reset clears fractional remainder")

		ScrollInputGate.reset()
		expect(ScrollInputGate.shouldSendTrackpadScroll(at: 1.0), true, "trackpad initially allowed")
		ScrollInputGate.recordGCMouseScroll(at: 1.0)
		expect(ScrollInputGate.shouldSendTrackpadScroll(at: 1.05), false, "trackpad suppressed after gcmouse")
		expect(ScrollInputGate.shouldSendTrackpadScroll(at: 1.30), true, "trackpad allowed after suppression")

		print("scroll mapping ok")
	}
}
