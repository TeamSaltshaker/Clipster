import SnapKit
import UIKit

final class SortOptionCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.font = .pretendard(size: 16, weight: .regular)
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .radioUnselected
        imageView.backgroundColor = .clear
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(title: String, isSelected: Bool, isAscending: Bool) {
        titleLabel.text = title
        titleLabel.textColor = isSelected ? .appPrimary : .textPrimary
        chevronImageView.isHidden = !isSelected
        chevronImageView.image = isAscending ? .chevronUpBlue: .chevronDownBlue
    }
}

private extension SortOptionCell {
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
        [
            titleLabel,
            chevronImageView
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.size.equalTo(24)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.trailing.equalTo(chevronImageView.snp.leading)
            make.centerY.equalToSuperview()
        }
    }
}
