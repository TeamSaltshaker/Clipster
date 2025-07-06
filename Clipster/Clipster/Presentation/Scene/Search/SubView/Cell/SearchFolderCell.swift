import SnapKit
import UIKit

final class SearchFolderCell: UICollectionViewListCell {
    private let folderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }()

    private let folderRowView = FolderRowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setDisplay(_ folder: FolderDisplay, query: String) {
        folderRowView.setDisplay(folder, query: query)
    }
}

private extension SearchFolderCell {
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
        [folderView]
            .forEach { contentView.addSubview($0) }

        [folderRowView]
            .forEach { folderView.addSubview($0) }
    }

    func setConstraints() {
        folderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        folderRowView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
    }
}
