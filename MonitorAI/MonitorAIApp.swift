import SwiftUI

@main
struct MonitorAIApp: App {
    @State private var coordinator: AppCoordinator

    init() {
        let container = DependencyContainer()
        _coordinator = State(initialValue: AppCoordinator(container: container))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                TopView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .userInfo:
                            UserInfoInputView()
                        case .camera:
                            CameraView(
                                viewModel: CameraViewModel(
                                    cameraService: coordinator.container.cameraService,
                                    configuration: coordinator.container.configuration
                                )
                            )
                        }
                    }
            }
            .environment(coordinator)
        }
    }
}
