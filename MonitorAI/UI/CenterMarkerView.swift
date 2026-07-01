import SwiftUI

struct CenterMarkerView: View {
    private let size: CGFloat = 20
    private let lineWidth: CGFloat = 1.5

    var body: some View {
        Canvas { context, canvasSize in
            let cx = canvasSize.width / 2
            let cy = canvasSize.height / 2
            let half = size / 2
            let color = Color.white.opacity(0.8)

            var h = Path()
            h.move(to: CGPoint(x: cx - half, y: cy))
            h.addLine(to: CGPoint(x: cx + half, y: cy))

            var v = Path()
            v.move(to: CGPoint(x: cx, y: cy - half))
            v.addLine(to: CGPoint(x: cx, y: cy + half))

            context.stroke(h, with: .color(color), lineWidth: lineWidth)
            context.stroke(v, with: .color(color), lineWidth: lineWidth)
        }
        .allowsHitTesting(false)
    }
}
