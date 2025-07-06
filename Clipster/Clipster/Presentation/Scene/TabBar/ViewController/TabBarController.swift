import RxRelay
import RxSwift
import SnapKit
import UIKit

final class TabBarViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let tabBarView = TabBarView()
    private weak var coordinator: TabBarCoordinator?

    private var currentVC: UIViewController?
    private let selectedTab = BehaviorRelay<TabBarMode>(value: .home)

    init(coordinator: TabBarCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = view.safeAreaInsets.bottom
        let tabBarHeight = bottomInset > 0 ? 100 : 64
        tabBarView.snp.updateConstraints {
            $0.height.equalTo(tabBarHeight)
        }
    }

    func switchTo(_ vc: UIViewController) {
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()

        addChild(vc)
        view.insertSubview(vc.view, belowSubview: tabBarView)

        vc.view.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(tabBarView.snp.top)
        }

        vc.didMove(toParent: self)
        currentVC = vc
    }
}

private extension TabBarViewController {
    func configure() {
        setHierarchy()
        setConstraints()
        setBindings()
    }

    func setHierarchy() {
        view.backgroundColor = .background
        view.addSubview(tabBarView)
    }

    func setConstraints() {
        let bottomInset = view.safeAreaInsets.bottom
        let tabBarHeight = bottomInset > 0 ? 100 : 64

        tabBarView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(tabBarHeight)
        }
    }

    func setBindings() {
        tabBarView.action
            .bind { [weak self] action in
                guard let self else { return }

                switch action {
                case .tapHome:
                    selectedTab.accept(.home)
                case .tapSearch:
                    selectedTab.accept(.search)
                case .tapUser:
                    selectedTab.accept(.myPage)
                }
            }
            .disposed(by: disposeBag)

        selectedTab
            .distinctUntilChanged()
            .subscribe { [weak self] mode in
                guard let self else { return }

                tabBarView.updateSelectedTab(mode)
                coordinator?.didSelect(tab: mode)
            }
            .disposed(by: disposeBag)
    }
}
