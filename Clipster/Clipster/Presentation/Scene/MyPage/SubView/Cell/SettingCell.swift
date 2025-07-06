import SnapKit
import UIKit

final class SettingCell: UICollectionViewCell {
    private let titleLabel = UILabel()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel, chevronImageView])
        stackView.axis = .horizontal
        stackView.spacing = 0
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
        valueLabel.isHidden = true
        chevronImageView.isHidden = true
        chevronImageView.image = nil
    }

    func setDisplay(_ item: MyPageItem) {
        titleLabel.text = item.titleText
        titleLabel.font = item.titleFont
        titleLabel.textColor = item.titleColor

        if let value = item.valueText {
            valueLabel.text = value
            valueLabel.font = item.valueFont
            valueLabel.textColor = item.valueColor
            valueLabel.isHidden = false
        }

        if let icon = item.rightIcon {
            chevronImageView.image = icon
            chevronImageView.isHidden = false
        }
    }
}

private extension SettingCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background
        contentView.backgroundColor = .cell
    }

    func setHierarchy() {
        contentView.addSubview(stackView)
    }

    func setConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
