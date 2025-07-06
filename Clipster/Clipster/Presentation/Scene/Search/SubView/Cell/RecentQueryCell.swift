import RxSwift
import SnapKit
import UIKit

final class RecentQueryCell: UICollectionViewCell {
    var disposeBag = DisposeBag()

    let queryLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 14, weight: .regular)
        label.textColor = .blue600
        return label
    }()

    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(.xGray.withTintColor(.secondaryLabel), for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            contentView.layer.applyDynamicBorderColor(color: .dialogueStroke, for: traitCollection)
        }
    }

    func setDisplay(_ query: String) {
        queryLabel.text = query
    }
}

private extension RecentQueryCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background
        contentView.backgroundColor = .cell
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = UIColor.textTertiary.cgColor
    }

    func setHierarchy() {
        [queryLabel, deleteButton]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        queryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }

        deleteButton.snp.makeConstraints { make in
            make.leading.equalTo(queryLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.verticalEdges.equalToSuperview().inset(5)
            make.size.equalTo(18)
        }
    }
}
