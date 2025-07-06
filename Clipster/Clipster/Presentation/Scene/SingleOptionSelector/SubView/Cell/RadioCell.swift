import SnapKit
import UIKit

final class RadioCell: UITableViewCell {
    private let radioLabelView = RadioLabelView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(title: String, isSelected: Bool) {
        radioLabelView.setDisplay(title: title, isSelected: isSelected)
    }
}

private extension RadioCell {
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
        [
            radioLabelView
        ].forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        radioLabelView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
