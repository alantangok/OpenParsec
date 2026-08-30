import Foundation
import CoreGraphics

enum ScrollWheelMapper {
	private static let wheelDivisor: Float = 20.0

	static func wheelScale(sensitivity: Float, naturalScrolling: Bool) -> Float {
		let direction: Float = naturalScrolling ? -1.0 : 1.0
		return sensitivity * direction / wheelDivisor
	}

	static func wheelUnits(rawDelta: Float, sensitivity: Float, naturalScrolling: Bool) -> Int32 {
		return Int32(rawDelta * wheelScale(sensitivity: sensitivity, naturalScrolling: naturalScrolling))
	}
}

struct ScrollWheel {
	let x: Int32
	let y: Int32
}

enum GCMouseScrollAxis {
	case x
	case y
}

enum GCMouseScrollMapper {
	static func adjustedDelta(axis: GCMouseScrollAxis, rawValue: Float, naturalScrolling: Bool) -> (x: Float, y: Float) {
		let direction: Float = naturalScrolling ? -1.0 : 1.0
		let adjusted = rawValue * direction
		switch axis {
		case .x:
			return (x: 0, y: adjusted)
		case .y:
			return (x: adjusted, y: 0)
		}
	}
}

struct GCMouseScrollMotion {
	private var accumulatedX: Float = 0
	private var accumulatedY: Float = 0
	private(set) var velocityX: Float = 0
	private(set) var velocityY: Float = 0
	private(set) var lastEventTime: TimeInterval?

	mutating func consume(
		axis: GCMouseScrollAxis,
		rawValue: Float,
		naturalScrolling: Bool,
		at time: TimeInterval
	) -> ScrollWheel {
		let delta = GCMouseScrollMapper.adjustedDelta(
			axis: axis,
			rawValue: rawValue,
			naturalScrolling: naturalScrolling
		)

		if let lastEventTime {
			let elapsed = Float(time - lastEventTime)
			if elapsed > 0.0005 && elapsed < 0.1 {
				switch axis {
				case .x:
					velocityY = velocityY * 0.4 + (delta.y / elapsed) * 0.6
				case .y:
					velocityX = velocityX * 0.4 + (delta.x / elapsed) * 0.6
				}
			} else if elapsed >= 0.1 {
				velocityX = 0
				velocityY = 0
			}
		}
		lastEventTime = time

		return accumulate(deltaX: delta.x, deltaY: delta.y)
	}

	mutating func momentumWheel(deltaTime: Float, decayPerSecond: Double) -> ScrollWheel {
		let decay = Float(pow(decayPerSecond, Double(deltaTime)))
		velocityX *= decay
		velocityY *= decay
		return accumulate(deltaX: velocityX * deltaTime, deltaY: velocityY * deltaTime)
	}

	func shouldStartMomentum(minimumSpeed: Float) -> Bool {
		return speed >= minimumSpeed
	}

	func shouldStopMomentum(maximumSpeed: Float) -> Bool {
		return speed < maximumSpeed
	}

	mutating func reset() {
		accumulatedX = 0
		accumulatedY = 0
		velocityX = 0
		velocityY = 0
		lastEventTime = nil
	}

	private var speed: Float {
		return sqrt(velocityX * velocityX + velocityY * velocityY)
	}

	private mutating func accumulate(deltaX: Float, deltaY: Float) -> ScrollWheel {
		accumulatedX += deltaX
		accumulatedY += deltaY
		let wheel = ScrollWheel(x: Int32(accumulatedX), y: Int32(accumulatedY))
		accumulatedX -= Float(wheel.x)
		accumulatedY -= Float(wheel.y)
		return wheel
	}
}

enum ScrollInputGate {
	private static let trackpadSuppressionWindow: TimeInterval = 0.20
	private static var lastGCMouseScrollTime: TimeInterval?

	static func recordGCMouseScroll(at time: TimeInterval = Date().timeIntervalSinceReferenceDate) {
		lastGCMouseScrollTime = time
	}

	static func shouldSendTrackpadScroll(at time: TimeInterval = Date().timeIntervalSinceReferenceDate) -> Bool {
		guard let lastGCMouseScrollTime else {
			return true
		}

		return time - lastGCMouseScrollTime >= trackpadSuppressionWindow
	}

	static func reset() {
		lastGCMouseScrollTime = nil
	}
}

enum PointerInputGate {
	static func status(
		windowIsFocused: Bool,
		appIsActive: Bool,
		sceneIsForegroundActive: Bool
	) -> PointerInputStatus {
		return PointerInputStatus(
			windowIsFocused: windowIsFocused,
			appIsActive: appIsActive,
			sceneIsForegroundActive: sceneIsForegroundActive
		)
	}

	static func isActive(
		windowIsFocused: Bool,
		appIsActive: Bool,
		sceneIsForegroundActive: Bool
	) -> Bool {
		return status(
			windowIsFocused: windowIsFocused,
			appIsActive: appIsActive,
			sceneIsForegroundActive: sceneIsForegroundActive
		).isActive
	}
}

struct PointerInputStatus {
	let windowIsFocused: Bool
	let appIsActive: Bool
	let sceneIsForegroundActive: Bool

	var isActive: Bool {
		return windowIsFocused && appIsActive && sceneIsForegroundActive
	}
}

enum GCMousePointerMapper {
	static func shouldSendRelativeMove(pointerHoverSupported: Bool) -> Bool {
		return !pointerHoverSupported
	}
}

enum PointerPositionMapper {
	static func hostPosition(
		pointerLocation: CGPoint,
		visibleFrame: CGRect,
		contentSize: CGSize,
		windowIsFocused: Bool = true,
		appIsActive: Bool = true,
		sceneIsForegroundActive: Bool = true
	) -> CGPoint? {
		guard PointerInputGate.isActive(
			windowIsFocused: windowIsFocused,
			appIsActive: appIsActive,
			sceneIsForegroundActive: sceneIsForegroundActive
		) else {
			return nil
		}
		guard visibleFrame.width > 0, visibleFrame.height > 0, contentSize.width > 0, contentSize.height > 0 else {
			return nil
		}
		guard visibleFrame.contains(pointerLocation) else {
			return nil
		}

		let relativeX = (pointerLocation.x - visibleFrame.minX) / visibleFrame.width
		let relativeY = (pointerLocation.y - visibleFrame.minY) / visibleFrame.height
		return CGPoint(x: relativeX * contentSize.width, y: relativeY * contentSize.height)
	}
}
