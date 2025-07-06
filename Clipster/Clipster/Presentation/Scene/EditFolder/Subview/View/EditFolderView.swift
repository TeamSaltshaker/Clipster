import RxSwift
import SnapKit
import UIKit

final class EditFolderView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()
    let saveButton = SaveButton()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.textColor = .textPrimary
        label.font = .pretendard(size: 16, weight: .medium)
        return label
    }()

    let folderTitleTextField = CommonTextField(type: .folder)
    let selectedFolderView = SelectedFolderView(type: .folder, mode: .edit)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setTextFieldInteraction(enabled: Bool) {
        folderTitleTextField.isUserInteractionEnabled = enabled
    }
}

private extension EditFolderView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background

        commonNavigationView.setLeftItem(backButton)
        commonNavigationView.setRightItem(saveButton)
    }

    func setHierarchy() {
        [commonNavigationView, titleLabel, folderTitleTextField, selectedFolderView]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        commonNavigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        saveButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom).offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(28)
        }

        folderTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        selectedFolderView.snp.makeConstraints { make in
            make.top.equalTo(folderTitleTextField.snp.bottom).offset(40)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualToSuperview().inset(24)
        }
    }
}
