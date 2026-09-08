import CoreGraphics
import Foundation

@main
struct CheckPointerMapping {
	static func expect(_ actual: CGPoint?, _ expected: CGPoint, _ label: String) {
		guard let actual else {
			fatalError("\(label): expected \(expected), got nil")
		}
		if abs(actual.x - expected.x) > 0.001 || abs(actual.y - expected.y) > 0.001 {
			fatalError("\(label): expected \(expected), got \(actual)")
		}
	}

	static func expectNil(_ actual: CGPoint?, _ label: String) {
		if let actual {
			fatalError("\(label): expected nil, got \(actual)")
		}
	}

	static func main() {
		let visibleFrame = CGRect(x: 20, y: 40, width: 200, height: 100)
		let contentSize = CGSize(width: 1000, height: 500)

		expect(
			PointerPositionMapper.hostPosition(
				pointerLocation: CGPoint(x: 120, y: 90),
				visibleFrame: visibleFrame,
				contentSize: contentSize
			),
			CGPoint(x: 500, y: 250),
			"center maps by relative position"
		)

		expect(
			PointerPositionMapper.hostPosition(
				pointerLocation: CGPoint(x: 20, y: 40),
				visibleFrame: visibleFrame,
				contentSize: contentSize
			),
			CGPoint(x: 0, y: 0),
			"top-left maps to origin"
		)

		expectNil(
			PointerPositionMapper.hostPosition(
				pointerLocation: CGPoint(x: 19, y: 40),
				visibleFrame: visibleFrame,
				contentSize: contentSize
			),
			"outside visible frame ignored"
		)

		let pointerStatus = PointerInputStatus(
			windowIsFocused: true,
			appIsActive: false,
			sceneIsForegroundActive: true
		)
		if pointerStatus.isActive {
			fatalError("inactive app status should not be active")
		}
		if GCMousePointerMapper.shouldSendRelativeMove(hasActiveConnection: false) {
			fatalError("gcmouse move should be blocked without a connection")
		}
		if !GCMousePointerMapper.shouldSendRelativeMove(hasActiveConnection: true) {
			fatalError("connected gcmouse move should be allowed regardless of focus or hover support")
		}
		if GCMousePointerMapper.shouldSendButton(pointerButtonTouchSupported: true) {
			fatalError("gcmouse buttons should be blocked when UIKit pointer buttons are supported")
		}
		if !GCMousePointerMapper.shouldSendButton(pointerButtonTouchSupported: false) {
			fatalError("gcmouse buttons should be allowed without UIKit pointer button support")
		}

		print("pointer mapping ok")
	}
}
