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
		if PointerInputGate.prefersPointerLocked && !GCMousePointerMapper.shouldSendRelativeMove(pointerHoverSupported: true) {
			fatalError("recovery must not lock the pointer while relative movement is blocked")
		}

		let recoveryStates: [(String, Bool, Bool, Bool, Bool)] = [
			("focused", true, true, true, true),
			("switch app", true, false, false, false),
			("return before scene activation", true, true, false, false),
			("app recovered", true, true, true, true),
			("window unfocused", false, true, true, false),
			("window refocused", true, true, true, true),
			("PiP background", false, false, false, false),
			("PiP restored", true, true, true, true),
		]
		for (label, focused, active, foreground, expected) in recoveryStates {
			let position = PointerPositionMapper.hostPosition(
				pointerLocation: CGPoint(x: 80, y: 60),
				visibleFrame: CGRect(x: 0, y: 0, width: 200, height: 100),
				contentSize: CGSize(width: 1000, height: 500),
				windowIsFocused: focused, appIsActive: active, sceneIsForegroundActive: foreground
			)
			if expected { expect(position, CGPoint(x: 400, y: 300), label) }
			else { expectNil(position, label) }
		}

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

		expectNil(
			PointerPositionMapper.hostPosition(
				pointerLocation: CGPoint(x: 120, y: 90),
				visibleFrame: visibleFrame,
				contentSize: contentSize,
				windowIsFocused: false
			),
			"unfocused window ignored"
		)

		expectNil(
			PointerPositionMapper.hostPosition(
				pointerLocation: CGPoint(x: 120, y: 90),
				visibleFrame: visibleFrame,
				contentSize: contentSize,
				appIsActive: false
			),
			"inactive app ignored"
		)

		expectNil(
			PointerPositionMapper.hostPosition(
				pointerLocation: CGPoint(x: 120, y: 90),
				visibleFrame: visibleFrame,
				contentSize: contentSize,
				sceneIsForegroundActive: false
			),
			"inactive scene ignored"
		)

		if PointerInputGate.isActive(windowIsFocused: true, appIsActive: false, sceneIsForegroundActive: true) {
			fatalError("inactive app should block pointer input")
		}

		let pointerStatus = PointerInputStatus(
			windowIsFocused: true,
			appIsActive: false,
			sceneIsForegroundActive: true
		)
		if pointerStatus.isActive {
			fatalError("inactive app status should not be active")
		}
		if GCMousePointerMapper.shouldSendRelativeMove(pointerHoverSupported: true) {
			fatalError("gcmouse move should be blocked when absolute hover is supported")
		}
		if !GCMousePointerMapper.shouldSendRelativeMove(pointerHoverSupported: false) {
			fatalError("gcmouse move should be allowed without absolute hover support")
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
