import SnapKit
import UIKit

final class ClipDetailView: UIView {
    let backButton = ClipDetailBackButton()
    let editButton = ClipDetailEditButton()
    let deleteButton = ClipDetailDeleteButton()

    private let clipView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let urlMetadataStackView = URLMetadataStackView(type: .detail)

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()

    private let rowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 14
        return stackView
    }()

    private let addedOnRow = ClipDetailRowView(title: "추가됨")
    private let lastVisitedRow = ClipDetailRowView(title: "최근 열람")
    private let folderRow = ClipDetailRowView(title: "저장 위치")

    private let memoView = ClipDetailMemoView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ clipDisplay: ClipDisplay, _ folderTitle: String) {
        urlMetadataStackView.setDisplay(model: clipDisplay.urlMetadata)
        addedOnRow.setDisplay(clipDisplay.createdAt)
        lastVisitedRow.setDisplay(clipDisplay.lastVisitedAt)
        folderRow.setDisplay(folderTitle)
        memoView.setDisplay(clipDisplay.memo)
    }
}

private extension ClipDetailView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .systemBackground
    }

    func setHierarchy() {
        [clipView, memoView]
            .forEach { addSubview($0) }

        [urlMetadataStackView, separator, rowStackView]
            .forEach { clipView.addSubview($0) }

        [addedOnRow, lastVisitedRow, folderRow]
            .forEach { rowStackView.addArrangedSubview($0) }
    }

    func setConstraints() {
        clipView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(16)
        }

        memoView.snp.makeConstraints { make in
            make.top.equalTo(clipView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }

        urlMetadataStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }

        separator.snp.makeConstraints { make in
            make.top.equalTo(urlMetadataStackView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(0.7)
        }

        rowStackView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}
