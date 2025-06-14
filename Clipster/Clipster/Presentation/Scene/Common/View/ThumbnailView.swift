import SnapKit
import UIKit

final class ThumbnailView: UIView {
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black800
        imageView.image = .none
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 16, weight: .semiBold)
        label.textColor = .black100
        label.numberOfLines = 2
        label.backgroundColor = .clear
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ThumbnailView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.black900.cgColor
        backgroundColor = .white900
    }

    func setHierarchy() {
        [thumbnailImageView, titleLabel]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(96)
            make.height.equalTo(72)
        }

        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.lessThanOrEqualToSuperview().inset(12)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)
        }
    }
}
