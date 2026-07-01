import AVFoundation
import CoreImage

protocol CameraServiceProtocol: AnyObject, Sendable {
    var previewLayer: AVCaptureVideoPreviewLayer { get }

    func startSession() async throws
    func stopSession() async
    func setTorchLevel(_ level: Float) async throws
    func setZoomFactor(_ factor: CGFloat) async throws
    func setFocusPoint(_ point: CGPoint) async throws
    func capturePhoto() async throws -> CIImage
}
