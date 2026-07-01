import SwiftUI

enum AppRoute: Hashable {
    case userInfo
    case camera
}

@MainActor
@Observable
final class AppCoordinator {
    var path = NavigationPath()
    let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func navigateToUserInfo() {
        path.append(AppRoute.userInfo)
    }

    func navigateToCamera() {
        path.append(AppRoute.camera)
    }
}
