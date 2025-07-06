import UIKit

final class BackButton: UIButton {
    convenience init(_ title: String?) {
        self.init(frame: .zero)

        if let title = title {
            setTitle(title, for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension BackButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        let hasTitle = (title(for: .normal)?.isEmpty == false)
        let pointSize: CGFloat = hasTitle ? 12 : 16

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        let image = UIImage.chevronLeft
            .withConfiguration(symbolConfig)
            .withTintColor(.textPrimary, renderingMode: .alwaysOriginal)

        var config = UIButton.Configuration.plain()
        config.image = image
        config.imagePadding = 4
        config.contentInsets = .zero

        configuration = config

        titleLabel?.font = .pretendard(size: 14, weight: .medium)
        setTitleColor(.textPrimary, for: .normal)
        setTitleColor(.textPrimary, for: .highlighted)

        contentHorizontalAlignment = .leading
    }
}
