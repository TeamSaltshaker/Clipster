import MessageUI
import UIKit

final class MyPageCoordinator: NSObject, Coordinator {
    private let diContainer: DIContainer

    let navigationController: UINavigationController
    weak var parent: Coordinator?
    var children: [Coordinator] = []

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        showMyPage()
    }
}

extension MyPageCoordinator {
    func showMyPage() {
        let reactor = diContainer.makeMyPageReactor()
        let vc = MyPageViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func editNickname(
        nickname: String,
        onSave: @escaping (String) -> Void
    ) {
        let vc = EditNicknameViewController(
            currentNickname: nickname,
            onSave: onSave
        )

        vc.modalPresentationStyle = .pageSheet

        navigationController.present(vc, animated: true)
    }

    func showSelectTheme(
        current: ThemeOption,
        options: [ThemeOption],
        onSelect: @escaping (ThemeOption) -> Void
    ) {
        let vc = SingleOptionSelectorViewController<ThemeOption>(
            title: "테마",
            options: options,
            selected: current,
            onSelect: onSelect
        )

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in 290 }]
        }

        navigationController.present(vc, animated: true)
    }

    func showSelectFolderSort(
        title: String,
        current: FolderSortOption,
        options: [FolderSortOption],
        onSelect: @escaping (FolderSortOption) -> Void
    ) {
        let vc = SortOptionSelectorViewController<FolderSortOption>(
            title: title,
            options: options,
            selected: current,
            onSelect: onSelect
        )

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in 290 }]
        }

        navigationController.present(vc, animated: true)
    }

    func showSelectClipSort(
        title: String,
        current: ClipSortOption,
        options: [ClipSortOption],
        onSelect: @escaping (ClipSortOption) -> Void
    ) {
        let vc = SortOptionSelectorViewController<ClipSortOption>(
            title: title,
            options: options,
            selected: current,
            onSelect: onSelect
        )

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in 290 }]
        }

        navigationController.present(vc, animated: true)
    }

    func showSelectSavePathLayout(
        current: SavePathOption,
        onSelect: @escaping (SavePathOption) -> Void
    ) {
        let vc = SavePathOptionSelectorViewController(
            selected: current,
            onSelect: onSelect
        )

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in 290 }]
        }

        navigationController.present(vc, animated: true)
    }

    func showAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func showInquiryMail() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(
                title: InquiryMail.Alert.title,
                message: InquiryMail.Alert.message,
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "확인", style: .default))
            navigationController.topViewController?.present(alert, animated: true)
            return
        }

        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([InquiryMail.recipient])
        mailVC.setSubject(InquiryMail.subject)
        mailVC.setMessageBody(InquiryMail.body(), isHTML: false)

        navigationController.topViewController?.present(mailVC, animated: true)
    }
}

extension MyPageCoordinator: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
