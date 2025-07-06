import SnapKit
import UIKit

final class SearchTextField: UITextField {
    private let textPadding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 48)

    let clearButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = .xGray.withTintColor(.textSecondary)
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
        button.configuration = config
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
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
}

private extension SearchTextField {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        let placeholderText = "검색"
        let commontFont = UIFont.pretendard(size: 16, weight: .medium)
        let placeholderColor = UIColor.textTertiary

        let spacerAttachment = NSTextAttachment()
        spacerAttachment.bounds = CGRect(x: 0, y: 0, width: 12, height: 0)

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = .searchGray.withTintColor(.textPrimary)
        let imageSize: CGFloat = 24
        let imageOffsetY = (commontFont.capHeight - imageSize) / 2
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageSize, height: imageSize)

        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(attachment: spacerAttachment))
        fullString.append(NSAttributedString(string: placeholderText, attributes: [
            .foregroundColor: placeholderColor,
            .font: commontFont
        ]))

        textColor = .textPrimary
        attributedPlaceholder = fullString
        rightView = clearButton
        rightViewMode = .whileEditing
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        smartDashesType = .no
        smartInsertDeleteType = .no
        layer.cornerRadius = 12
        backgroundColor = .cell
        font = commontFont
    }
}
