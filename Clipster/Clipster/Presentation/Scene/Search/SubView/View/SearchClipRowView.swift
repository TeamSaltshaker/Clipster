import SnapKit
import UIKit

final class SearchClipRowView: UIView {
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
        label.textColor = .textPrimary
        return label
    }()

    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 12, weight: .regular)
        label.textColor = .textSecondary
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setDisplay(_ clip: ClipDisplay, query: String = "") {
        if let imageData = clip.urlMetadata.screenshotImageData,
           let image = UIImage(data: imageData) {
            thumbnailImageView.image = image
        } else if let url = clip.urlMetadata.thumbnailImageURL {
            thumbnailImageView.kf.setImage(with: url)
        } else {
            thumbnailImageView.image = .none
        }

        let title = clip.urlMetadata.title
        let memo = clip.isShowSubTitle ? clip.subTitle : clip.memo
        let url = clip.urlMetadata.url.absoluteString
        if !query.isEmpty {
            titleLabel.attributedText = title.highlight(query: query, foregroundColor: .textPrimary, font: .pretendard(size: 16, weight: .semiBold))
            memoLabel.attributedText = memo.highlight(query: query, foregroundColor: .textPrimary, font: .pretendard(size: 12, weight: .regular))
            urlLabel.attributedText = url.highlight(query: query, foregroundColor: .textSecondary, font: .pretendard(size: 12, weight: .regular))
        } else {
            titleLabel.text = title
            memoLabel.text = memo
            urlLabel.text = memo
        }
    }
}

private extension SearchClipRowView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .clear
    }

    func setHierarchy() {
        [thumbnailImageView, titleLabel, memoLabel, urlLabel]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.bottom.equalToSuperview().priority(.high)
            make.width.equalTo(91)
            make.height.equalTo(68)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
        }

        memoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
        }

        urlLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(thumbnailImageView)
        }
    }
}
