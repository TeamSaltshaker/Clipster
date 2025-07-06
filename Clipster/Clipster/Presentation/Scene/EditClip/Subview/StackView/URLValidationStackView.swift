import SnapKit
import UIKit

final class URLValidationStackView: UIStackView {
    let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .none
        return imageView
    }()

    let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textSecondary
        label.font = .pretendard(size: 12, weight: .regular)
        label.text = " "
        return label
    }()

    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .textPrimary
        return activityIndicatorView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension URLValidationStackView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        spacing = 8
    }

    func setHierarchy() {
        [
            statusImageView,
            statusLabel
        ].forEach {
            addArrangedSubview($0)
        }

        statusImageView.addSubview(activityIndicatorView)
    }

    func setConstraints() {
        statusImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }

        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension URLValidationStackView {
    func setHiddenAnimated(_ hidden: Bool, duration: TimeInterval = 0.25) {
        if hidden {
            UIView.animate(withDuration: duration) {
                self.alpha = 0
                self.isHidden = true
            }
        } else {
            self.isHidden = false
            self.alpha = 0
            UIView.animate(withDuration: duration) {
                self.alpha = 1
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
