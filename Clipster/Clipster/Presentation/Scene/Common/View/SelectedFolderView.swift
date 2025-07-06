import SnapKit
import UIKit

final class SelectedFolderView: UIView {
    enum SelectedFolderType {
        case clip
        case folder
    }

    enum SelectedFolderMode {
        case edit
        case detail
    }

    private let type: SelectedFolderType
    private let mode: SelectedFolderMode

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "저장폴더"
        label.textColor = .textPrimary
        label.font = .pretendard(size: 16, weight: .medium)
        return label
    }()

    let addButton = AddButton()

    let folderView: UIView = {
        let view = UIView()
        view.backgroundColor = .cell
        view.layer.cornerRadius = 12
        return view
    }()

    let folderRowView = FolderRowView()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevronRight.withTintColor(.textPrimary)
        imageView.contentMode = .right
        return imageView
    }()

    let folderViewTapGesture = UITapGestureRecognizer()

    init(type: SelectedFolderType, mode: SelectedFolderMode) {
        self.type = type
        self.mode = mode
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SelectedFolderView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    func setAttributes() {
        switch (type, mode) {
        case (.clip, .edit):
            addButton.isHidden = false
            chevronImageView.isHidden = false
        case (.clip, .detail):
            addButton.isHidden = true
            chevronImageView.isHidden = true
        case (.folder, _):
            addButton.isHidden = true
            chevronImageView.isHidden = false
        }
    }

    func setHierarchy() {
        [titleLabel, addButton, folderView]
            .forEach { addSubview($0) }

        [folderRowView, chevronImageView]
            .forEach { folderView.addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(4)
        }

        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(4)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(48)
        }

        folderView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.directionalHorizontalEdges.equalToSuperview()
            make.height.equalTo(72)
            make.bottom.equalToSuperview()
        }

        folderRowView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(folderRowView.snp.trailing)
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(48)
        }
    }

    func setBindings() {
        folderView.addGestureRecognizer(folderViewTapGesture)
    }
}
