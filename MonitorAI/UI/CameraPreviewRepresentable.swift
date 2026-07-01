import SwiftUI
import AVFoundation

struct CameraPreviewRepresentable: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    let onTap: (CGPoint, CGSize) -> Void

    func makeUIView(context: Context) -> TapablePreviewView {
        let view = TapablePreviewView()
        view.onTap = onTap
        return view
    }

    func updateUIView(_ uiView: TapablePreviewView, context: Context) {
        uiView.setPreviewLayer(previewLayer)
    }
}

final class TapablePreviewView: UIView {
    var onTap: ((CGPoint, CGSize) -> Void)?
    private var currentLayer: AVCaptureVideoPreviewLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError() }

    func setPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
        currentLayer?.removeFromSuperlayer()
        layer.frame = bounds
        self.layer.insertSublayer(layer, at: 0)
        currentLayer = layer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        currentLayer?.frame = bounds
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        onTap?(point, bounds.size)
    }
}
