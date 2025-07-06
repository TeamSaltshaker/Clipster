import UIKit

final class AddFAButton: UIButton {
    private let innerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .appPrimary
        button.setImage(.plus.withTintColor(.white900), for: .normal)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 8
        button.layer.masksToBounds = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(
            roundedRect: innerButton.bounds,
            cornerRadius: innerButton.layer.cornerRadius
        )
        innerButton.layer.shadowPath = path.cgPath
    }
}

extension AddFAButton {
    override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willDisplayMenuFor configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        animator?.addAnimations {
            self.innerButton.transform = CGAffineTransform(rotationAngle: .pi / 4)
        }
    }

    override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willEndFor configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        animator?.addAnimations {
            self.innerButton.transform = .identity
        }
    }
}

private extension AddFAButton {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .clear
    }

    func setHierarchy() {
        addSubview(innerButton)
    }

    func setConstraints() {
        self.snp.makeConstraints { make in
            make.size.equalTo(68)
        }

        innerButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(56)
        }
    }
}
