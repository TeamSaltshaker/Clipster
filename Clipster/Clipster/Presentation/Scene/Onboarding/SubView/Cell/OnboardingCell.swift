import SnapKit
import UIKit

final class OnboardingCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 22, weight: .bold)
        label.textColor = .blue600
        label.textAlignment = .center
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 18, weight: .regular)
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ item: OnboardingItem) {
        titleLabel.text = item.title
        imageView.image = item.image
        descriptionLabel.text = item.description
    }
}

private extension OnboardingCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        contentView.backgroundColor = .clear
    }

    func setHierarchy() {
        [
            titleLabel,
            imageView,
            descriptionLabel
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.height.equalTo(31)
            make.centerX.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(80)
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-24)
            make.height.greaterThanOrEqualTo(100).priority(.low)
        }
    }
}
