import RxSwift
import SnapKit
import UIKit

final class RecentVisitedClipCell: UICollectionViewCell {
    var disposeBag = DisposeBag()

    private let searchClipRowView = SearchClipRowView()

    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(.xGray.withTintColor(.textSecondary), for: .normal)
        button.contentHorizontalAlignment = .center
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func setDisplay(_ clip: ClipDisplay) {
        searchClipRowView.setDisplay(clip)
    }
}

private extension RecentVisitedClipCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background
        contentView.backgroundColor = .cell
        contentView.layer.cornerRadius = 12
    }

    func setHierarchy() {
        [searchClipRowView, deleteButton]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        searchClipRowView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.verticalEdges.equalToSuperview().inset(12)
        }

        deleteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(searchClipRowView.snp.trailing)
            make.size.equalTo(48)
        }
    }
}
