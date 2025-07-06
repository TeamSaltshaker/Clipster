import SnapKit
import UIKit

final class MemoView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "메모"
        label.font = .pretendard(size: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()

    private let memoContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.dialogueStroke.cgColor
        view.backgroundColor = .cell
        return view
    }()

    let memoTextView: UITextView = {
        let textView = UITextView()
        textView.font = .pretendard(size: 14, weight: .regular)
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        return textView
    }()

    let memoLimitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .pretendard(size: 12, weight: .regular)
        label.textAlignment = .right
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
            memoContainerView.layer.applyDynamicBorderColor(color: .dialogueStroke, for: traitCollection)
        }
    }
}

private extension MemoView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [titleLabel, memoContainerView]
            .forEach { addSubview($0) }

        [memoTextView, memoLimitLabel]
            .forEach { memoContainerView.addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview().inset(4)
        }

        memoContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.directionalHorizontalEdges.equalToSuperview()
            make.height.equalTo(96)
        }

        memoTextView.snp.makeConstraints { make in
            make.top.directionalHorizontalEdges.equalToSuperview().inset(12)
        }

        memoLimitLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(12)
            make.bottom.directionalHorizontalEdges.equalToSuperview().inset(12)
        }
    }
}
