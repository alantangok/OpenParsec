import CoreGraphics

@main
struct CheckZoomViewport {
	static func expect(_ actual: Bool, _ expected: Bool, _ label: String) {
		if actual != expected {
			fatalError("\(label): expected \(expected), got \(actual)")
		}
	}

	static func main() {
		expect(
			ZoomViewportPolicy.shouldConstrain(zoomEnabled: true, zoomScale: 1.0, minimumZoomScale: 1.0),
			false,
			"original zoom is unconstrained"
		)
		expect(
			ZoomViewportPolicy.shouldConstrain(zoomEnabled: true, zoomScale: 1.005, minimumZoomScale: 1.0),
			false,
			"near-original zoom is unconstrained"
		)
		expect(
			ZoomViewportPolicy.shouldConstrain(zoomEnabled: false, zoomScale: 2.0, minimumZoomScale: 1.0),
			false,
			"disabled pinch zoom is unconstrained"
		)
		expect(
			ZoomViewportPolicy.shouldConstrain(zoomEnabled: true, zoomScale: 1.5, minimumZoomScale: 1.0),
			true,
			"active zoom remains constrained"
		)

		print("zoom viewport policy ok")
	}
}
