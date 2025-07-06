import SnapKit
import UIKit

final class FolderListCell: UICollectionViewListCell {
    private let folderImageContainerView: UIView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .iconBG
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.iconStroke.cgColor
        return imageView
    }()

    private let folderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .folderBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 16, weight: .semiBold)
        label.textColor = .textPrimary
        label.numberOfLines = 1
        return label
    }()

    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 12, weight: .regular)
        label.textColor = .textSecondary
        label.numberOfLines = 1
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, itemCountLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevronRight.withTintColor(.textPrimary)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            folderImageContainerView.layer.applyDynamicBorderColor(color: .dialogueStroke, for: traitCollection)
        }
    }

    func setDisplay(_ display: FolderDisplay) {
        titleLabel.text = display.title
        itemCountLabel.text = display.itemCount
    }
}

private extension FolderListCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = .cell
        background.cornerRadius = 12
        background.backgroundInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 0)
        self.backgroundConfiguration = background
    }

    func setHierarchy() {
        [
            folderImageContainerView,
            stackView,
            chevronImageView
        ].forEach { contentView.addSubview($0) }

        folderImageContainerView.addSubview(folderImageView)
    }

    func setConstraints() {
        folderImageContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().inset(12).priority(.high)
            make.size.equalTo(48)
        }

        folderImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(14)
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalTo(folderImageContainerView.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(stackView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(24)
            make.size.equalTo(24)
            make.centerY.equalToSuperview()
        }
    }
}
