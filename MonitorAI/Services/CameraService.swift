import AVFoundation
import CoreImage

final class CameraService: NSObject, CameraServiceProtocol, @unchecked Sendable {
    let previewLayer: AVCaptureVideoPreviewLayer

    private let session: AVCaptureSession
    private let sessionQueue = DispatchQueue(label: "com.gosign.MonitorAI.camera", qos: .userInitiated)
    private var videoDevice: AVCaptureDevice?
    private let photoOutput = AVCapturePhotoOutput()
    private let configuration: AppConfiguration

    init(configuration: AppConfiguration) {
        self.configuration = configuration
        let session = AVCaptureSession()
        self.session = session
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init()
        self.previewLayer.videoGravity = .resizeAspectFill
    }

    func startSession() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let self else { return }
                do {
                    try self.configureSession()
                    self.session.startRunning()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func stopSession() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sessionQueue.async { [weak self] in
                self?.session.stopRunning()
                continuation.resume()
            }
        }
    }

    func setTorchLevel(_ level: Float) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let device = self?.videoDevice else {
                    continuation.resume(throwing: CameraError.deviceUnavailable)
                    return
                }
                do {
                    try device.lockForConfiguration()
                    if level > 0, device.isTorchAvailable {
                        try device.setTorchModeOn(level: level)
                    } else {
                        device.torchMode = .off
                    }
                    device.unlockForConfiguration()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func setZoomFactor(_ factor: CGFloat) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let device = self?.videoDevice else {
                    continuation.resume(throwing: CameraError.deviceUnavailable)
                    return
                }
                do {
                    try device.lockForConfiguration()
                    let clamped = min(max(factor, 1.0), device.activeFormat.videoMaxZoomFactor)
                    device.videoZoomFactor = clamped
                    device.unlockForConfiguration()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func setFocusPoint(_ point: CGPoint) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let device = self?.videoDevice else {
                    continuation.resume(throwing: CameraError.deviceUnavailable)
                    return
                }
                do {
                    try device.lockForConfiguration()
                    if device.isFocusPointOfInterestSupported {
                        device.focusPointOfInterest = point
                        device.focusMode = .autoFocus
                    }
                    device.unlockForConfiguration()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func capturePhoto() async throws -> CIImage {
        let currentZoom = videoDevice?.videoZoomFactor ?? 1.0
        try await setZoomFactor(1.0)
        defer {
            Task { try await self.setZoomFactor(currentZoom) }
        }

        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(throwing: CameraError.deviceUnavailable)
                    return
                }
                let settings = AVCapturePhotoSettings()
                settings.flashMode = .off
                let delegate = PhotoCaptureDelegate(continuation: continuation)
                self.photoOutput.capturePhoto(with: settings, delegate: delegate)
                // Keep delegate alive until callback
                _ = delegate
            }
        }
    }

    private func configureSession() throws {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CameraError.deviceUnavailable
        }
        self.videoDevice = device

        session.beginConfiguration()
        session.sessionPreset = .photo

        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else { throw CameraError.configurationFailed }
        session.addInput(input)

        guard session.canAddOutput(photoOutput) else { throw CameraError.configurationFailed }
        session.addOutput(photoOutput)

        if let connection = photoOutput.connection(with: .video) {
            if connection.isVideoRotationAngleSupported(0) {
                connection.videoRotationAngle = 0
            }
        }

        if let previewConnection = previewLayer.connection {
            if previewConnection.isVideoRotationAngleSupported(0) {
                previewConnection.videoRotationAngle = 0
            }
        }

        session.commitConfiguration()

        try device.lockForConfiguration()
        try device.setTorchModeOn(level: configuration.torchDefaultLevel)
        device.unlockForConfiguration()
    }
}

enum CameraError: Error {
    case deviceUnavailable
    case configurationFailed
    case captureFailed
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, Sendable {
    private let continuation: CheckedContinuation<CIImage, Error>

    init(continuation: CheckedContinuation<CIImage, Error>) {
        self.continuation = continuation
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            continuation.resume(throwing: error)
            return
        }
        guard let data = photo.fileDataRepresentation(),
              let ciImage = CIImage(data: data) else {
            continuation.resume(throwing: CameraError.captureFailed)
            return
        }
        continuation.resume(returning: ciImage)
    }
}
