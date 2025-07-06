import SnapKit
import UIKit

final class FolderSelectorView: UIView {
    private var tableViewBottomConstraint: Constraint?
    private var tableViewHorizontalConstraint: Constraint?

    let commonNavigationView: CommonNavigationView = {
        let commonNavigationView = CommonNavigationView()
        commonNavigationView.backgroundColor = .cell
        return commonNavigationView
    }()

    let backButton = BackButton("이전폴더")
    let selectButton = SelectButton()
    let confirmButton = ConfirmButton()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .textTertiary
        return view
    }()

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(AccordionCell.self, forCellReuseIdentifier: AccordionCell.identifier)
        tableView.register(FolderSelectorCell.self, forCellReuseIdentifier: FolderSelectorCell.identifier)
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 12
        return tableView
    }()

    private let baseBackgroundView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ isAccordion: Bool) {
        if isAccordion {
            backgroundColor = .background
            baseBackgroundView.backgroundColor = .background
            commonNavigationView.backgroundColor = .background
            separator.isHidden = true
            tableView.backgroundColor = .cell
            commonNavigationView.setRightItem(confirmButton)
            tableViewBottomConstraint?.update(inset: 34)
            tableViewHorizontalConstraint?.update(inset: 24)
        } else {
            backgroundColor = .background
            baseBackgroundView.backgroundColor = .cell
            commonNavigationView.backgroundColor = .clear
            separator.isHidden = false
            tableView.backgroundColor = .clear
            commonNavigationView.setLeftItem(backButton)
            commonNavigationView.setRightItem(selectButton)
            tableViewBottomConstraint?.update(inset: 0)
            tableViewHorizontalConstraint?.update(inset: 0)
        }
    }
}

private extension FolderSelectorView {
    func configure() {
        setHierarchy()
        setConstraints()
    }

    func setHierarchy() {
        [baseBackgroundView, commonNavigationView, separator, tableView]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        baseBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        commonNavigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        selectButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        confirmButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        separator.snp.makeConstraints { make in
            make.top.equalTo(commonNavigationView.snp.bottom)
            make.directionalHorizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            tableViewBottomConstraint = make.bottom.equalToSuperview().constraint
            tableViewHorizontalConstraint = make.directionalHorizontalEdges.equalToSuperview().constraint
        }
    }
}
