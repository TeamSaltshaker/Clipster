import UIKit

final class CancelButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CancelButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        let normalFont = UIFont.pretendard(size: 16, weight: .semiBold)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.textPrimary
        ]

        setAttributedTitle(NSAttributedString(string: "취소", attributes: normalAttributes), for: .normal)

        contentHorizontalAlignment = .leading
    }
}
