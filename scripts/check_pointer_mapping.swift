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
		let focused = PointerInputStatus(windowIsFocused: true, appIsActive: true, sceneIsForegroundActive: true)
		let anotherWindow = PointerInputStatus(windowIsFocused: false, appIsActive: true, sceneIsForegroundActive: true)
		let inactiveApp = PointerInputStatus(windowIsFocused: true, appIsActive: false, sceneIsForegroundActive: true)
		let inactiveScene = PointerInputStatus(windowIsFocused: true, appIsActive: true, sceneIsForegroundActive: false)
		let transitions: [(String, PointerInputStatus, Bool, Bool, Bool, Bool)] = [
			("initial foreground", focused, true, false, true, true),
			("another window focused", anotherWindow, true, false, true, false),
			("refocus", focused, true, false, true, true),
			("app switching", inactiveApp, true, false, true, false),
			("scene still inactive", inactiveScene, true, false, true, false),
			("app switch recovery", focused, true, false, true, true),
			("PiP active despite foreground scene", focused, true, true, true, false),
			("PiP stopped before view appears", focused, false, false, true, false),
			("PiP restored", focused, true, false, true, true),
			("disconnected", focused, true, false, false, false),
			("reconnected", focused, true, false, true, true),
		]
		for (label, status, visible, pip, connected, expected) in transitions {
			let allowed = PointerInputGate.shouldSendMovement(
				hasActiveConnection: connected, status: status,
				viewIsVisible: visible, isPiPActive: pip
			)
			if allowed != expected { fatalError("focus transition failed: \(label)") }
		}

		if PointerPositionMapper.shouldSendAbsoluteMove(pointerIsLocked: true, hasGCMouse: false) {
			fatalError("locked pointer must not snap to UIKit absolute coordinates on click")
		}
		if !PointerPositionMapper.shouldSendAbsoluteMove(pointerIsLocked: false, hasGCMouse: false) {
			fatalError("unlocked pointer must retain absolute hover movement")
		}
		// Press, release/unlock, and hover resumption must keep the same movement source.
		for pointerIsLocked in [true, false, false, true] {
			if PointerPositionMapper.shouldSendAbsoluteMove(pointerIsLocked: pointerIsLocked, hasGCMouse: true) {
				fatalError("connected trackpad must not drift to hover coordinates after button release")
			}
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
			fatalError("connected gcmouse passes connection eligibility before the controller focus gate")
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
