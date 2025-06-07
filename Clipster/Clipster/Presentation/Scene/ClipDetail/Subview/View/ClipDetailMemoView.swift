import SnapKit
import UIKit

final class ClipDetailMemoView: UIView {
    private let memoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "메모"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
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

    func setDisplay(_ memo: String) {
        memoLabel.text = memo
    }
}

private extension ClipDetailMemoView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
    }

    func setHierarchy() {
        [memoTitleLabel, memoLabel]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        memoTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTitleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(memoTitleLabel)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}
