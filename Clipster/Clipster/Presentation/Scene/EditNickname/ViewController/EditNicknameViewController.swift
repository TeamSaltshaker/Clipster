import RxSwift
import UIKit

final class EditNicknameViewController: UIViewController {
    private let editNicknameView = EditNicknameView()

    private let disposeBag = DisposeBag()

    private var nickname: String
    private let onSave: (String) -> Void

    init(currentNickname: String, onSave: @escaping (String) -> Void) {
        self.nickname = currentNickname
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = editNicknameView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        editNicknameView.setDisplay(nickname)
    }
}

private extension EditNicknameViewController {
    func configure() {
        setBindings()
    }

    func setBindings() {
        editNicknameView.action
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self]action in
                guard let self else { return }

                switch action {
                case .changeNickname(let changedNickname):
                    nickname = changedNickname
                    let isSavable = !changedNickname
                        .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    editNicknameView.setSaveButtonEnabled(isSavable)
                case .tapSave:
                    onSave(nickname)
                    dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}
