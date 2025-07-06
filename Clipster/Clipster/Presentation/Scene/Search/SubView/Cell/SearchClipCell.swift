import SnapKit
import UIKit

final class SearchClipCell: UICollectionViewListCell {
    private let searchClipRowView = SearchClipRowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setDisplay(_ clip: ClipDisplay, query: String) {
        searchClipRowView.setDisplay(clip, query: query)
    }
}

private extension SearchClipCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = .cell
        background.cornerRadius = 12
        background.backgroundInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        self.backgroundConfiguration = background
    }

    func setHierarchy() {
        [searchClipRowView]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        searchClipRowView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
    }
}
