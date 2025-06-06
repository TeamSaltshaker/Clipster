import UIKit

final class ClipDetailEditButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension ClipDetailEditButton {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        setImage(UIImage(systemName: "pencil"), for: .normal)
        tintColor = .label
    }
}
