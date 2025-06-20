import UIKit

final class CommonNavigationView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 22, weight: .bold)
        label.textColor = .black100
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stackView
    }()

    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func setLeftItem(_ item: UIButton) {
        leftStackView.addArrangedSubview(item)
    }

    func setLeftItems(_ items: [UIButton]) {
        items.forEach {
            leftStackView.addArrangedSubview($0)
        }
    }

    func setRightItem(_ item: UIButton) {
        rightStackView.addArrangedSubview(item)
    }

    func setRightItems(_ items: [UIButton]) {
        items.forEach {
            rightStackView.addArrangedSubview($0)
        }
    }
}

private extension CommonNavigationView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [titleLabel, leftStackView, rightStackView]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        snp.makeConstraints { make in
            make.height.equalTo(56)
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        leftStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.lessThanOrEqualTo(titleLabel.snp.leading).offset(-26)
            make.centerY.equalToSuperview()
        }

        rightStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(26)
            make.centerY.equalToSuperview()
        }
    }
}
