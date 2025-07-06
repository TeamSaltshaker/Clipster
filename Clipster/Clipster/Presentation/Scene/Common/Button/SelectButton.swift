import UIKit

final class SelectButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension SelectButton {
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
            .foregroundColor: UIColor.appPrimary
        ]

        setAttributedTitle(NSAttributedString(string: "선택", attributes: normalAttributes), for: .normal)
        setAttributedTitle(NSAttributedString(string: "선택", attributes: disabledAttributes), for: .disabled)

        contentHorizontalAlignment = .trailing
    }
}
