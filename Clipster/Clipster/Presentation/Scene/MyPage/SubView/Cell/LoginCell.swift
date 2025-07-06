import SnapKit
import UIKit

final class LoginCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 14, weight: .semiBold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            contentView.layer.applyDynamicBorderColor(color: .dialogueStroke, for: traitCollection)
        }
    }

    func setDisplay(_ login: LoginType) {
        imageView.image = login.icon
        titleLabel.text = login.title
    }
}

private extension LoginCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background
        contentView.backgroundColor = .cell
        contentView.layer.cornerRadius = 24
        contentView.layer.borderColor = UIColor.dialogueStroke.cgColor
        contentView.layer.borderWidth = 1
    }

    func setHierarchy() {
        [
            stackView
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }

        stackView.snp.makeConstraints { make in
            make.width.equalTo(138)
            make.center.equalToSuperview()
        }
    }
}
