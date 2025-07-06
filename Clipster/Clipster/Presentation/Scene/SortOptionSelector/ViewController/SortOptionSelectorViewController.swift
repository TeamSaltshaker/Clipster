import RxSwift
import SnapKit
import UIKit

final class SortOptionSelectorViewController<Option: SortableOption>: UIViewController {
    typealias Section = Int
    typealias Item = Option

    let disposeBag = DisposeBag()

    private var options: [Option]
    private var selected: Option
    private let onSelect: (Option) -> Void
    private var dataSource: UITableViewDiffableDataSource<Section, Item>?

    private let baseBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .cell
        return view
    }()

    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = .textPrimary
        view.layer.cornerRadius = 2.5
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.font = .pretendard(size: 16, weight: .semiBold)
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .textTertiary
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = 48
        tableView.backgroundColor = .clear
        tableView.register(SortOptionCell.self, forCellReuseIdentifier: SortOptionCell.identifier)
        return tableView
    }()

    init(
        title: String,
        options: [Option],
        selected: Option,
        onSelect: @escaping (Option) -> Void
    ) {
        self.options = options.map {
            $0.isSameSortBasis(as: selected) ? selected : $0
        }
        self.selected = selected
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureDataSource()
        applySnapshot()
    }

    private func configureDataSource() {
        dataSource = .init(tableView: tableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SortOptionCell.identifier,
                for: indexPath
            ) as? SortOptionCell else { return UITableViewCell() }

            let isSelected = item.isSameSortBasis(as: self.selected)
            cell.setDisplay(
                title: item.displayText,
                isSelected: isSelected,
                isAscending: item.isAscending
            )
            cell.selectionStyle = .none
            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Option>()
        snapshot.appendSections([0])
        snapshot.appendItems(options)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func updateSelection(_ newSelected: Option) {
        if newSelected.isSameSortBasis(as: selected) {
            let toggled = selected.toggled()
            selected = toggled
            onSelect(toggled)

            if let index = options.firstIndex(where: { $0.isSameSortBasis(as: toggled) }) {
                options[index] = toggled
            }

            applySnapshot()
        } else {
            let oldSelected = selected
            selected = newSelected
            onSelect(newSelected)

            guard var snapshot = dataSource?.snapshot() else { return }
            snapshot.reconfigureItems([oldSelected, newSelected])
            dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
}

private extension SortOptionSelectorViewController {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    func setAttributes() {
        view.backgroundColor = .background
    }

    func setHierarchy() {
        [
            baseBackgroundView,
            grabberView,
            titleLabel,
            separatorView,
            tableView
        ].forEach { view.addSubview($0) }
    }

    func setConstraints() {
        baseBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        grabberView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.width.equalTo(134)
            make.height.equalTo(5)
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func setBindings() {
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let self,
                      let selected = dataSource?.itemIdentifier(for: indexPath)
                else { return }
                self.updateSelection(selected)
            }
            .disposed(by: disposeBag)
    }
}
