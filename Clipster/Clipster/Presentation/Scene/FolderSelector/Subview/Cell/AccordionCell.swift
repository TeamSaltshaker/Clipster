import RxSwift
import SnapKit
import UIKit

final class AccordionCell: UITableViewCell {
    private var cellLeadingConstraint: Constraint?

    var disposeBag = DisposeBag()

    private let imageContainerView = UIView()

    private let homeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .homeBlue
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private let folderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .folderBlue
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(size: 18, weight: .semiBold)
        label.textColor = .textSecondary
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let chevronRightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevronRightBlue
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private let chevronDownImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevronDownBlue
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private let fullWidthSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .textTertiary
        return view
    }()

    private let insetSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .textTertiary
        return view
    }()

    let expandAreaButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func setDisplay(_ folder: FolderDisplay) {
        titleLabel.text = folder.title
        countLabel.text = folder.folderCount
        countLabel.isHidden = (folder.folderCount == "0" || folder.folderCount.isEmpty)

        if folder.depth == -1 {
            titleLabel.font = .pretendard(size: 18, weight: .semiBold)
            homeImageView.isHidden = false
            folderImageView.isHidden = true
        } else {
            titleLabel.font = .pretendard(size: 18, weight: .regular)
            homeImageView.isHidden = true
            folderImageView.isHidden = false
        }

        if folder.hasSubfolders {
            expandAreaButton.isUserInteractionEnabled = true
            chevronRightImageView.isHidden = folder.isExpanded
            chevronDownImageView.isHidden = !folder.isExpanded
        } else {
            expandAreaButton.isUserInteractionEnabled = false
            chevronRightImageView.isHidden = true
            chevronDownImageView.isHidden = true
        }

        if folder.isHighlighted {
            titleLabel.font = .pretendard(size: 18, weight: .semiBold)
            titleLabel.textColor = .appPrimary
        } else {
            titleLabel.font = .pretendard(size: 18, weight: .regular)
            titleLabel.textColor = .textPrimary
        }

        updateCellLeadingConstraint(depth: folder.depth)
    }

    func setSeparator(_ isLastCell: Bool, for depth: Int) {
        if isLastCell && depth != -1 {
            fullWidthSeparatorView.isHidden = true
            insetSeparatorView.isHidden = true
        } else {
            let isHome = (depth == -1)
            fullWidthSeparatorView.isHidden = !isHome
            insetSeparatorView.isHidden = isHome
        }
    }

    private func updateCellLeadingConstraint(depth: Int) {
        let defaultIndent = 16
        let initialIndent = defaultIndent + 8
        let stepIndent = depth * 12

        guard depth >= 0 else {
            cellLeadingConstraint?.update(offset: defaultIndent)
            return
        }

        cellLeadingConstraint?.update(offset: initialIndent + stepIndent)
    }
}

private extension AccordionCell {
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
        [homeImageView, folderImageView]
            .forEach { imageContainerView.addSubview($0) }

        [
            imageContainerView,
            titleLabel,
            countLabel,
            chevronRightImageView,
            chevronDownImageView,
            fullWidthSeparatorView,
            insetSeparatorView,
            expandAreaButton
        ]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        imageContainerView.snp.makeConstraints { make in
            cellLeadingConstraint = make.leading.equalToSuperview().constraint
            make.centerY.equalToSuperview()
            make.size.equalTo(44)
        }

        homeImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.size.equalTo(24)
        }

        folderImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
            make.size.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageContainerView.snp.trailing)
            make.centerY.equalToSuperview()
        }

        countLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }

        chevronRightImageView.snp.makeConstraints { make in
            make.leading.equalTo(countLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        chevronDownImageView.snp.makeConstraints { make in
            make.edges.equalTo(chevronRightImageView)
            make.size.equalTo(24)
        }

        fullWidthSeparatorView.snp.makeConstraints { make in
            make.directionalHorizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        insetSeparatorView.snp.makeConstraints { make in
            make.leading.equalTo(imageContainerView)
            make.trailing.equalTo(chevronRightImageView)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        expandAreaButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(countLabel)
            make.trailing.equalToSuperview()
        }
    }
}
