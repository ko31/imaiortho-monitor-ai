import AVFoundation
import SwiftUI

@MainActor
@Observable
final class CameraViewModel {
    enum State {
        case idle, running, error(String)
    }

    private(set) var state: State = .idle
    private(set) var currentZoom: CGFloat
    var availableZoomLevels: [CGFloat]

    private let cameraService: any CameraServiceProtocol
    private let configuration: AppConfiguration

    var previewLayer: AVCaptureVideoPreviewLayer {
        cameraService.previewLayer
    }

    init(cameraService: any CameraServiceProtocol, configuration: AppConfiguration) {
        self.cameraService = cameraService
        self.configuration = configuration
        self.availableZoomLevels = configuration.previewZoomLevels
        self.currentZoom = configuration.defaultPreviewZoom
    }

    func startCamera() async {
        do {
            try await cameraService.startSession()
            try await cameraService.setZoomFactor(currentZoom)
            state = .running
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func stopCamera() async {
        await cameraService.stopSession()
        state = .idle
    }

    func selectZoom(_ zoom: CGFloat) async {
        currentZoom = zoom
        do {
            try await cameraService.setZoomFactor(zoom)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func handleTapFocus(at point: CGPoint, in size: CGSize) async {
        guard size.width > 0, size.height > 0 else { return }
        let normalized = CGPoint(
            x: point.x / size.width,
            y: point.y / size.height
        )
        do {
            try await cameraService.setFocusPoint(normalized)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
