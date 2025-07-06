import SnapKit
import UIKit

final class URLView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "URL"
        label.font = .pretendard(size: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()

    let urlTextField: CommonTextField = {
        let textField = CommonTextField(type: .clip)
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension URLView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [titleLabel, urlTextField]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview().inset(4)
        }

        urlTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.directionalHorizontalEdges.equalToSuperview()
            make.height.equalTo(48)
        }
    }
}
