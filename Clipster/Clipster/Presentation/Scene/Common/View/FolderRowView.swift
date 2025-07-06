import SnapKit
import UIKit

final class FolderRowView: UIView {
    private let folderImageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .iconBG
        view.layer.borderColor = UIColor.iconStroke.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        return view
    }()

    private let folderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .folderBlue
        return imageView
    }()

    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.font = .pretendard(size: 16, weight: .semiBold)
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textSecondary
        label.font = .pretendard(size: 12, weight: .regular)
        return label
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
            folderImageBackgroundView.layer.applyDynamicBorderColor(color: .dialogueStroke, for: traitCollection)
        }
    }

    func setDisplay(_ folder: FolderDisplay?, query: String = "") {
        let title = folder?.title ?? "홈"
        if !query.isEmpty {
            titleLabel.attributedText = title.highlight(query: query, foregroundColor: .textPrimary, font: .pretendard(size: 16, weight: .semiBold))
        } else {
            titleLabel.text = title
        }
        countLabel.text = folder?.itemCount
        countLabel.isHidden = folder == nil
    }
}

private extension FolderRowView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [folderImageBackgroundView, labelStackView]
            .forEach { addSubview($0) }

        folderImageBackgroundView.addSubview(folderImageView)

        [titleLabel, countLabel]
            .forEach { labelStackView.addArrangedSubview($0) }
    }

    func setConstraints() {
        folderImageBackgroundView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(.high)
            make.size.equalTo(48)
        }

        labelStackView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.leading.equalTo(folderImageBackgroundView.snp.trailing).offset(16)
        }

        folderImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }
    }
}
