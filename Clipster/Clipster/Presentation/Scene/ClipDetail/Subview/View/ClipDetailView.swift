import Kingfisher
import SnapKit
import UIKit

final class ClipDetailView: UIView {
    let commonNavigationView = CommonNavigationView()
    let backButton = BackButton()
    let editButton = EditButton()
    let deleteButton = DeleteButton()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let urlMetadataStackView = URLMetadataStackView()

    private let urlView: URLView = {
        let view = URLView()
        view.urlTextField.mode = .detail
        return view
    }()

    private let memoView: MemoView = {
        let view = MemoView()
        view.memoTextView.textColor = .textSecondary
        view.memoTextView.isEditable = false
        return view
    }()

    private let selectedFolderView = SelectedFolderView(type: .clip, mode: .detail)

    private let recentVisitedDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textSecondary
        label.font = .pretendard(size: 12, weight: .regular)
        return label
    }()

    private let recentEditedDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textSecondary
        label.font = .pretendard(size: 12, weight: .regular)
        return label
    }()

    private let createdDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textSecondary
        label.font = .pretendard(size: 12, weight: .regular)
        return label
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ clip: ClipDisplay, folder: FolderDisplay?) {
        urlMetadataStackView.setDisplay(display: clip.urlMetadata)
        urlView.urlTextField.text = clip.urlMetadata.url.description
        memoView.memoTextView.text = clip.memo
        memoView.memoLimitLabel.text = clip.memoLimit
        selectedFolderView.folderRowView.setDisplay(folder)
        recentVisitedDateLabel.text = clip.recentVisitedDate
        recentEditedDateLabel.text = clip.recentEditedDate
        createdDateLabel.text = clip.createdDate
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            memoView.isHidden = true
            activityIndicator.startAnimating()
        } else {
            memoView.isHidden = false
            activityIndicator.stopAnimating()
        }
    }
}

private extension ClipDetailView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background

        commonNavigationView.setTitle("상세정보")
        commonNavigationView.setLeftItem(backButton)
        commonNavigationView.setRightItems([editButton, deleteButton])
    }

    func setHierarchy() {
        [
            commonNavigationView,
            scrollView
        ]
            .forEach { addSubview($0) }

        scrollView.addSubview(contentView)

        [
            urlMetadataStackView,
            urlView,
            memoView,
            selectedFolderView,
            activityIndicator,
            recentVisitedDateLabel,
            recentEditedDateLabel,
            createdDateLabel
        ]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        commonNavigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        editButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom)
            make.directionalHorizontalEdges.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }

        urlMetadataStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        urlView.snp.makeConstraints { make in
            make.top.equalTo(urlMetadataStackView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        memoView.snp.makeConstraints { make in
            make.top.equalTo(urlView.snp.bottom).offset(32)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        selectedFolderView.snp.makeConstraints { make in
            make.top.equalTo(memoView.snp.bottom).offset(40)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
        }

        recentVisitedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(selectedFolderView.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
        }

        recentEditedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(recentVisitedDateLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        createdDateLabel.snp.makeConstraints { make in
            make.top.equalTo(recentEditedDateLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
