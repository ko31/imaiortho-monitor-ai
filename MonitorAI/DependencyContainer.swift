import Foundation

@MainActor
final class DependencyContainer {
    let configuration: AppConfiguration
    let cameraService: any CameraServiceProtocol

    init() {
        self.configuration = AppConfiguration()
        self.cameraService = CameraService(configuration: configuration)
    }
}
