import MessageUI
import ReactorKit
import UIKit

final class MyPageViewController: UIViewController, View {
    typealias Reactor = MyPageReactor

    var disposeBag = DisposeBag()
    private let myPageView = MyPageView()
    private weak var coordinator: MyPageCoordinator?

    init(reactor: Reactor, coordinator: MyPageCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = myPageView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.viewWillAppear)
    }

    func bind(reactor: Reactor) {
        bindAction(to: reactor)
        bindState(from: reactor)
        bindRoute(from: reactor)
    }
}

extension MyPageViewController {
    func bindAction(to reactor: Reactor) {
        myPageView.action
            .bind { [weak self] action in
                guard let self else { return }

                switch action {
                case .tapCell(let item):
                    if case let .account(accountItem) = item {
                        self.handleAccountItem(accountItem)
                    } else {
                        reactor.action.onNext(.tapCell(item))
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    func bindState(from reactor: Reactor) {
        reactor.state
            .map { $0.sectionModel }
            .distinctUntilChanged { lhs, rhs in
                guard lhs.count == rhs.count else { return false }

                for (lhsModel, rhsModel) in zip(lhs, rhs) {
                    if lhsModel.section != rhsModel.section || lhsModel.items != rhsModel.items {
                        return false
                    }
                }

                return true
            }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] sections in
                guard let self else { return }

                myPageView.setDisplay(sections)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$isScrollToTop)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                guard let self else { return }

                myPageView.scrollToTop(animated: false)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$phase)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] phase in
                guard let self else { return }

                switch phase {
                case .loading:
                    myPageView.showLoading()
                case .success:
                    myPageView.hideLoading()
                case .error(let message):
                    myPageView.hideLoading()
                    presentErrorAlert(message: message)
                case .idle:
                    break
                }
            }
            .disposed(by: disposeBag)
    }

    func bindRoute(from reactor: Reactor) {
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] route in
                guard let self else { return }

                switch route {
                case .showEditNickName(let nickname):
                    coordinator?.editNickname(
                        nickname: nickname
                    ) { [weak self] changedNickname in
                        self?.reactor?.action.onNext(.changeNickName(changedNickname))
                    }

                case .showSelectTheme(let currentOption, let availableOptions):
                    coordinator?.showSelectTheme(
                        current: currentOption,
                        options: availableOptions
                    ) { [weak self] selected in
                        self?.reactor?.action.onNext(.changeTheme(selected))
                    }
                case .showSelectFolderSort(let currentOption, let availableOptions):
                    coordinator?.showSelectFolderSort(
                        title: "폴더 정렬 순서",
                        current: currentOption,
                        options: availableOptions
                    ) { [weak self] selected in
                        self?.reactor?.action.onNext(.changeFolderSort(selected))
                    }
                case .showSelectClipSort(let currentOption, let availableOptions):
                    coordinator?.showSelectClipSort(
                        title: "클립 정렬 순서",
                        current: currentOption,
                        options: availableOptions
                    ) { [weak self] selected in
                        self?.reactor?.action.onNext(.changeClipSort(selected))
                    }
                case .showSelectSavePathLayout(let currentOption, _):
                    coordinator?.showSelectSavePathLayout(
                        current: currentOption
                    ) { [weak self] selected in
                        self?.reactor?.action.onNext(.changeSavePathLayout(selected))
                    }
                case .showNotificationSetting:
                    coordinator?.showAppSettings()
                case .showTrash:
                    break
                case .showSupport:
                    coordinator?.showInquiryMail()
                }
            }
            .disposed(by: disposeBag)
    }
}

private extension MyPageViewController {
    func handleAccountItem(_ accountItem: AccountItem) {
        let alert: UIAlertController

        switch accountItem {
        case .logout:
            alert = UIAlertController(
                title: "로그아웃",
                message: "하시겠습니까?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
                self?.reactor?.action.onNext(.tapCell(.account(.logout)))
            })

        case .withdraw:
            alert = UIAlertController(
                title: "회원탈퇴",
                message: "하시겠습니까?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "탈퇴", style: .destructive) { [weak self] _ in
                self?.reactor?.action.onNext(.tapCell(.account(.withdraw)))
            })
        }

        present(alert, animated: true)
    }
}
