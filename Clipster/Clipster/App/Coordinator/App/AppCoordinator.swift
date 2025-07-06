import UIKit

final class AppCoordinator: Coordinator {
    private let diContainer: DIContainer

    let navigationController: UINavigationController
    weak var parent: Coordinator?
    var children: [Coordinator] = []

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    deinit {
        print("\(Self.self) 메모리 해제")
    }

    func start() {
        applySavedTheme()

        let hasSeen = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        if hasSeen {
            showTab()
        } else {
            showOnboarding()
        }
    }
}

private extension AppCoordinator {
    func applySavedTheme() {
        let fetchThemeUseCase = diContainer.makeFetchThemeUseCase()
        Task {
            let theme = try? await fetchThemeUseCase.execute().get()
            await AppThemeManager.shared.apply(theme: theme ?? .system)
        }
    }
}

extension AppCoordinator {
    func showTab() {
        let tabBarCoordinator = TabBarCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
        addChild(tabBarCoordinator)
        tabBarCoordinator.start()
    }

    func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.onFinish = { [weak self] in
            guard let self else { return }

            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            navigationController.dismiss(animated: true)
            showTab()
        }
        onboardingVC.modalPresentationStyle = .fullScreen
        navigationController.present(onboardingVC, animated: false)
    }

    func handleSharedURL(_ urlString: String) {
        if let homeCoordinator = children.compactMap({ $0 as? HomeCoordinator }).first {
            homeCoordinator.showEditClipFromSharedURL(urlString: urlString)
        } else {
            print("HomeCoordinator가 아직 초기화되지 않았습니다.")
        }
    }
}
