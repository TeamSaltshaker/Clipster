import RxCocoa
import RxSwift
import UIKit

final class HomeViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let homeviewModel: HomeViewModel
    private let homeView = HomeView()

    init(homeviewModel: HomeViewModel) {
        self.homeviewModel = homeviewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        homeviewModel.action.accept(.viewWillAppear)
    }

    private func makeAddButtonMenu() -> UIMenu {
        let addFolderAction = UIAction(
            title: "폴더 추가",
            image: UIImage(systemName: "folder")
        ) { [weak self] _ in
            self?.homeviewModel.action.accept(.tapAddFolder)
        }

        let addClipAction = UIAction(
            title: "클립 추가",
            image: UIImage(systemName: "paperclip"),
        ) { [weak self] _ in
            self?.homeviewModel.action.accept(.tapAddClip)
        }

        return UIMenu(title: "", children: [addFolderAction, addClipAction])
    }
}

private extension HomeViewController {
    func configure() {
        setAttributes()
        setNavigationBarItems()
        setBindings()
    }

    func setAttributes() {
        title = "Clipster"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func setNavigationBarItems() {
        let infoButton = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            primaryAction: UIAction { [weak self] _ in
                self?.homeviewModel.action.accept(.tapLicense)
            }
        )

        let addButton = UIBarButtonItem(
            systemItem: .add,
            menu: makeAddButtonMenu()
        )

        navigationController?.navigationBar.tintColor = .label
        navigationItem.rightBarButtonItems = [infoButton, addButton]
    }

    func setBindings() {
        homeView.action
            .bind(with: self) { owner, action in
                switch action {
                case .tap(let indexPath):
                    owner.homeviewModel.action.accept(.tapCell(indexPath))
                case .detail(let indexPath):
                    owner.homeviewModel.action.accept(.tapDetail(indexPath))
                case .edit(let indexPath):
                    owner.homeviewModel.action.accept(.tapEdit(indexPath))
                case .delete(let indexPath):
                    owner.homeviewModel.action.accept(.tapDelete(indexPath))
                }
            }
            .disposed(by: disposeBag)

        homeviewModel.state
            .asSignal()
            .emit(with: self) { owner, state in
                switch state {
                case .homeDisplay(let homeDisplay):
                    owner.homeView.setDisplay(homeDisplay)
                }
            }
            .disposed(by: disposeBag)

        homeviewModel.route
            .asSignal()
            .emit(with: self) { _, route in
                switch route {
                case .showAddClip:
                    print("클립 추가 화면 이동\n")
                case .showAddFolder:
                    print("폴더 추가 화면 이동\n")
                case .showWebView(let url):
                    print("웹 뷰")
                    print("\(url)\n")
                case .showFolder(let folder):
                    print("폴더 화면 이동")
                    print("\(folder)\n")
                case .showDetailClip(let clip):
                    print("클립 상세 화면 이동")
                    print("\(clip)\n")
                case .showEditClip(let clip):
                    print("클립 편집 화면 이동")
                    print("\(clip)\n")
                case .showEditFolder(let folder):
                    print("폴더 편집 화면 이동\n")
                    print(folder)
                case .showLicense:
                    print("라이센스 화면 이동\n")
                }
            }
            .disposed(by: disposeBag)
    }
}
