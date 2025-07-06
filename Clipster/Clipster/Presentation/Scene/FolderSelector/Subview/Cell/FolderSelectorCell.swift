import SnapKit
import UIKit

final class FolderSelectorCell: UITableViewCell {
    private let folderRowView = FolderRowView()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevronRight.withTintColor(.textPrimary)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ folder: FolderDisplay) {
        folderRowView.setDisplay(folder)
    }
}

private extension FolderSelectorCell {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background
        contentView.backgroundColor = .cell
    }

    func setHierarchy() {
        [folderRowView, chevronImageView]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        folderRowView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(folderRowView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
    }
}
