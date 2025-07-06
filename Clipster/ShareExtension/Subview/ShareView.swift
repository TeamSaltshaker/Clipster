import SnapKit
import UIKit

final class ShareView: UIView {
    private let baseBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .cell
        return view
    }()

    let commonNavigationView: CommonNavigationView = {
        let commonNavigationView = CommonNavigationView()
        commonNavigationView.setTitle("클립 추가")
        commonNavigationView.setTitleLabelFont(.pretendard(size: 16, weight: .semiBold))
        return commonNavigationView
    }()

    let cancelButton = CancelButton()
    let saveButton = SaveButton()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    let scrollContainerView = UIView()

    private let urlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    let urlMetadataStackView: URLMetadataStackView = {
        let stackView = URLMetadataStackView()
        return stackView
    }()

    let urlTextField: CommonTextField = {
        let textField = CommonTextField(type: .clip)
        textField.mode = .edit
        return textField
    }()

    let urlValidationStacKView: URLValidationStackView = {
        let stackView = URLValidationStackView()
        stackView.isHidden = true
        return stackView
    }()

    let memoView = MemoView()

    let selectedFolderView: SelectedFolderView = {
        let view = SelectedFolderView(type: .clip, mode: .edit)
        view.addButton.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ShareView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background

        layer.masksToBounds = false
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 16

        commonNavigationView.setLeftItem(cancelButton)
        commonNavigationView.setRightItem(saveButton)
    }

    func setHierarchy() {
        [
            baseBackgroundView,
            commonNavigationView,
            scrollView
        ].forEach {
            addSubview($0)
        }

        [
            scrollContainerView
        ].forEach {
            scrollView.addSubview($0)
        }

        [
            urlStackView,
            memoView,
            selectedFolderView
        ].forEach {
            scrollContainerView.addSubview($0)
        }

        [
            urlMetadataStackView,
            urlTextField,
            urlValidationStacKView
        ].forEach {
            urlStackView.addArrangedSubview($0)
        }
    }

    func setConstraints() {
        baseBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        commonNavigationView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview()
        }

        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        saveButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom)
            make.directionalHorizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        scrollContainerView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        urlStackView.setCustomSpacing(16, after: urlStackView.arrangedSubviews[0])

        urlStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.width.equalToSuperview().inset(24)
            make.height.equalTo(0).priority(.low)
        }

        urlTextField.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        memoView.snp.makeConstraints { make in
            make.top.equalTo(urlStackView.snp.bottom).offset(16)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        selectedFolderView.snp.makeConstraints { make in
            make.top.equalTo(memoView.snp.bottom).offset(7)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}
