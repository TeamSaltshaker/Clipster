import SnapKit
import UIKit

final class CommonTextField: UITextField {
    enum TextFieldType {
        case clip
        case folder
    }

    enum TextFieldMode {
        case edit
        case detail
    }

    let type: TextFieldType
    var mode: TextFieldMode = .edit {
        didSet { setMode() }
    }

    private let textPadding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 48)

    let clearButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = .xGray
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
        button.configuration = config
        return button
    }()

    init(type: TextFieldType) {
        self.type = type
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textPadding)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textPadding)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.applyDynamicBorderColor(color: .dialogueStroke, for: traitCollection)
        }
    }

    private func setMode() {
        switch mode {
        case .edit:
            textColor = .textPrimary
        case .detail:
            textColor = .textSecondary
            isUserInteractionEnabled = false
        }
    }
}

private extension CommonTextField {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        let placeholder: String
        let commontFont = UIFont.pretendard(size: 14, weight: .regular)

        switch type {
        case .clip:
            placeholder = "URL을 입력해 주세요."
            keyboardType = .URL
        case .folder:
            placeholder = "제목을 입력해 주세요."
        }

        rightView = clearButton
        rightViewMode = .whileEditing
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        smartDashesType = .no
        smartInsertDeleteType = .no
        layer.borderWidth = 1
        layer.cornerRadius = 12
        layer.borderColor = UIColor.dialogueStroke.cgColor
        backgroundColor = .cell
        font = commontFont
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.textTertiary,
                .font: commontFont
            ]
        )
    }
}
