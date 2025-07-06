import Kingfisher
import SnapKit
import UIKit

final class ClipListCell: UICollectionViewListCell {
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black800
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 16, weight: .semiBold)
        label.textColor = .textPrimary
        return label
    }()

    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 12, weight: .regular)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, memoLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private let visitIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue600
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white900.cgColor
        view.isHidden = true
        return view
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
        thumbnailImageView.image = nil
    }

    func setDisplay(_ display: ClipDisplay) {
        if let thumbnailURL = display.urlMetadata.thumbnailImageURL {
            thumbnailImageView.kf.setImage(with: thumbnailURL)
        } else if let screenshotImageData = display.urlMetadata.screenshotImageData,
                  let screenshotImage = UIImage(data: screenshotImageData) {
            thumbnailImageView.image = screenshotImage
        } else {
            thumbnailImageView.image = .none
        }

        titleLabel.text = display.urlMetadata.title
        memoLabel.text = display.isShowSubTitle ? display.subTitle : display.memo
        visitIndicatorView.isHidden = display.isVisited
    }
}

private extension ClipListCell {
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
            thumbnailImageView,
            stackView,
            visitIndicatorView
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().inset(12).priority(.high)
            make.width.equalTo(64)
            make.height.equalTo(48)
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        visitIndicatorView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.leading).inset(6)
            make.top.equalTo(thumbnailImageView.snp.top).inset(6)
            make.size.equalTo(8)
        }
    }
}
