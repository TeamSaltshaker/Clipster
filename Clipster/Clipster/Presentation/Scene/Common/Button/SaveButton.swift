import UIKit

final class SaveButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension SaveButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        let normalFont = UIFont.pretendard(size: 16, weight: .semiBold)
        let disabledFont = UIFont.pretendard(size: 16, weight: .medium)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.appPrimary
        ]
        let disabledAttributes: [NSAttributedString.Key: Any] = [
            .font: disabledFont,
            .foregroundColor: UIColor.textTertiary
        ]

        setAttributedTitle(NSAttributedString(string: "저장", attributes: normalAttributes), for: .normal)
        setAttributedTitle(NSAttributedString(string: "저장", attributes: disabledAttributes), for: .disabled)

        contentHorizontalAlignment = .trailing
    }
}
