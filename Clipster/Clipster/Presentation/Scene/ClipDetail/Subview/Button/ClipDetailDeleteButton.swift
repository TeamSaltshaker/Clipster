import UIKit

final class ClipDetailDeleteButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension ClipDetailDeleteButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        setImage(UIImage(systemName: "trash"), for: .normal)
        tintColor = .systemRed
    }
}
