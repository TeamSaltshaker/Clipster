import SnapKit
import UIKit

final class ClipDetailBackButton: UIView {
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setDisplay(_ title: String) {
        titleLabel.text = title
    }
}

private extension ClipDetailBackButton {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [backButton, titleLabel]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.centerY.trailing.equalToSuperview()
        }
    }
}
