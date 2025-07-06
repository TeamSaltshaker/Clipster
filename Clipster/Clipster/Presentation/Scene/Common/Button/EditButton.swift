import UIKit

final class EditButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension EditButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        setImage(.pen.withTintColor(.textPrimary), for: .normal)
        contentHorizontalAlignment = .trailing
    }
}
