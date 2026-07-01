import SwiftUI

struct CameraView: View {
    @State var viewModel: CameraViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                CameraPreviewRepresentable(
                    previewLayer: viewModel.previewLayer
                ) { point, size in
                    Task { await viewModel.handleTapFocus(at: point, in: size) }
                }
                .ignoresSafeArea()

                GridOverlayView()
                    .ignoresSafeArea()

                CenterMarkerView()
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZoomSelectorView(
                            zoomLevels: viewModel.availableZoomLevels,
                            currentZoom: viewModel.currentZoom
                        ) { zoom in
                            Task { await viewModel.selectZoom(zoom) }
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }

                if case .error(let message) = viewModel.state {
                    Text(message)
                        .foregroundStyle(.red)
                        .padding()
                        .background(.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.startCamera()
        }
        .onDisappear {
            Task { await viewModel.stopCamera() }
        }
    }
}
