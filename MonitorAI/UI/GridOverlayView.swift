import SwiftUI

struct GridOverlayView: View {
    var body: some View {
        Canvas { context, size in
            let cols = 3
            let rows = 3
            let strokeColor = Color.white.opacity(0.4)
            var path = Path()

            for i in 1..<cols {
                let x = size.width * CGFloat(i) / CGFloat(cols)
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for i in 1..<rows {
                let y = size.height * CGFloat(i) / CGFloat(rows)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }

            context.stroke(path, with: .color(strokeColor), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}
