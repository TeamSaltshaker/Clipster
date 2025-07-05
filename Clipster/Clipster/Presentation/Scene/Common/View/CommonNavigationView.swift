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
        stackView.isHidden = true
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stackView
    }()

    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.isHidden = true
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

    func setTitleLabelFont(_ font: UIFont) {
        titleLabel.font = font
    }

    func setLeftItem(_ item: UIButton) {
        clearStackView(leftStackView)
        leftStackView.addArrangedSubview(item)
        leftStackView.isHidden = false
    }

    func setLeftItems(_ items: [UIButton]) {
        clearStackView(leftStackView)
        items.forEach {
            leftStackView.addArrangedSubview($0)
        }
        leftStackView.isHidden = false
    }

    func setRightItem(_ item: UIButton) {
        clearStackView(rightStackView)
        rightStackView.addArrangedSubview(item)
        rightStackView.isHidden = false
    }

    func setRightItems(_ items: [UIButton]) {
        clearStackView(rightStackView)
        items.forEach {
            rightStackView.addArrangedSubview($0)
        }
        rightStackView.isHidden = false
    }

    private func clearStackView(_ stackView: UIStackView) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        stackView.isHidden = true
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
            make.height.equalTo(48)
            make.centerY.equalToSuperview()
        }

        rightStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(26)
            make.height.equalTo(48)
            make.centerY.equalToSuperview()
        }
    }
}
