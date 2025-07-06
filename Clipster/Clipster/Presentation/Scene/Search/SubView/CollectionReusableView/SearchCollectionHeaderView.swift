import RxRelay
import RxSwift
import SnapKit
import UIKit

final class SearchCollectionHeaderView: UICollectionReusableView {
    var disposeBag = DisposeBag()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 18, weight: .semiBold)
        label.textColor = .textPrimary
        return label
    }()

    let deleteAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("전체 삭제", for: .normal)
        button.setTitleColor(.textSecondary, for: .normal)
        button.titleLabel?.font = .pretendard(size: 14, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.isHidden = true
        return button
    }()

    let countLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 14, weight: .medium)
        label.textColor = .textSecondary
        return label
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
        disposeBag = DisposeBag()
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func setDeleteAllButtonVisible(_ isVisible: Bool) {
        deleteAllButton.isHidden = !isVisible
    }

    func setCountLabelVisible(_ isVisible: Bool) {
        countLabel.isHidden = !isVisible
    }
}

private extension SearchCollectionHeaderView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [
            titleLabel,
            deleteAllButton,
            countLabel
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
        }

        deleteAllButton.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
        }

        countLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
        }
    }
}
