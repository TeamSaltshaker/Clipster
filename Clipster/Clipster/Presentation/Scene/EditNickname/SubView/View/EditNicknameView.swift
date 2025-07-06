import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class EditNicknameView: UIView {
    enum Action {
        case changeNickname(String)
        case tapSave
    }

    let action = PublishRelay<Action>()
    private let disposeBag = DisposeBag()

    private let baseBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .cell
        return view
    }()

    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = .textPrimary
        view.layer.cornerRadius = 2.5
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.text = "닉네임 변경"
        label.font = .pretendard(size: 16, weight: .semiBold)
        return label
    }()

    private let saveButton = SaveButton()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black800
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.textTertiary.cgColor
        return view
    }()

    private let nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = .pretendard(size: 12, weight: .regular)
        return label
    }()

    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.font = .pretendard(size: 16, weight: .semiBold)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ nickname: String) {
        nicknameTextField.becomeFirstResponder()
        nicknameTextField.text = nickname
    }

    func setSaveButtonEnabled(_ isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
    }
}

private extension EditNicknameView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    func setAttributes() {
        backgroundColor = .background
    }

    func setHierarchy() {
        [
            nicknameTitleLabel,
            nicknameTextField
        ].forEach { containerView.addSubview($0) }

        [
            baseBackgroundView,
            grabberView,
            titleLabel,
            saveButton,
            separatorView,
            containerView
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        baseBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        grabberView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.width.equalTo(134)
            make.height.equalTo(5)
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom)
            make.trailing.equalToSuperview().inset(24)
            make.size.equalTo(48)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }

        containerView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(75)
        }

        nicknameTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(24)
        }

        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
    }

    func setBindings() {
        nicknameTextField.rx.text.orEmpty
            .map { Action.changeNickname($0) }
            .bind(to: action)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .map { Action.tapSave }
            .bind(to: action)
            .disposed(by: disposeBag)

        let tap = UITapGestureRecognizer()
        containerView.addGestureRecognizer(tap)
        tap.rx.event
            .bind { [weak self] _ in
                self?.nicknameTextField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)
    }
}
