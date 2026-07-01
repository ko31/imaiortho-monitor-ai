import Foundation

struct AppConfiguration: Sendable {
    let torchDefaultLevel: Float = 0.7
    let torchMinLevel: Float = 0.0
    let torchMaxLevel: Float = 1.0

    let previewZoomLevels: [CGFloat] = [2.5, 3.0, 4.0]
    let defaultPreviewZoom: CGFloat = 2.5

    let overlayDefaultOpacity: Double = 0.5
    let overlayMinOpacity: Double = 0.3
    let overlayMaxOpacity: Double = 0.7
}
