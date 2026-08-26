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

enum GCMouseScrollMapper {
	static func yAxisWheel(rawValue: Float, naturalScrolling: Bool) -> ScrollWheel {
		return ScrollWheel(x: Int32(adjustedRawValue(rawValue, naturalScrolling: naturalScrolling)), y: 0)
	}

	static func xAxisWheel(rawValue: Float, naturalScrolling: Bool) -> ScrollWheel {
		return ScrollWheel(x: 0, y: Int32(adjustedRawValue(rawValue, naturalScrolling: naturalScrolling)))
	}

	private static func adjustedRawValue(_ rawValue: Float, naturalScrolling: Bool) -> Float {
		let direction: Float = naturalScrolling ? -1.0 : 1.0
		return rawValue * direction
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
