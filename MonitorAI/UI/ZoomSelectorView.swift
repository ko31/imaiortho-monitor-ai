import SwiftUI

struct ZoomSelectorView: View {
    let zoomLevels: [CGFloat]
    let currentZoom: CGFloat
    let onSelect: (CGFloat) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(zoomLevels, id: \.self) { zoom in
                Button {
                    onSelect(zoom)
                } label: {
                    Text(zoomLabel(zoom))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(currentZoom == zoom ? .black : .white)
                        .frame(width: 44, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(currentZoom == zoom ? Color.yellow : Color.black.opacity(0.5))
                        )
                }
            }
        }
        .padding(8)
    }

    private func zoomLabel(_ zoom: CGFloat) -> String {
        if zoom == zoom.rounded() {
            return "\(Int(zoom))x"
        }
        return String(format: "%.1fx", zoom)
    }
}
