import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class FolderView: UIView {
    enum Action {
        case didTapBackButton
        case didTapAddFolderButton
        case didTapAddClipButton
        case didTapCell(IndexPath)
        case didTapDetailButton(IndexPath)
        case didTapEditButton(IndexPath)
        case didTapDeleteButton(IndexPath, String)
    }

    enum Section: Int, CaseIterable {
        case folder
        case clip

        func logicalIndexPath(for item: Int) -> IndexPath {
            switch self {
            case .folder:
                IndexPath(item: item, section: 0)
            case .clip:
                IndexPath(item: item, section: 1)
            }
        }
    }

    enum Item: Hashable {
        case folder(FolderDisplay)
        case clip(ClipDisplay)

        var displayTitle: String {
            switch self {
            case .folder(let folder):
                folder.title
            case .clip(let clip):
                clip.urlMetadata.title
            }
        }
    }

    let action = PublishRelay<Action>()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private let disposeBag = DisposeBag()

    private let navigationView = CommonNavigationView()
    private let backButton = BackButton()

    private lazy var addButton: AddFAButton = {
        let button = AddFAButton()
        button.showsMenuAsPrimaryAction = true
        button.menu = makeAddButtonMenu()
        button.preferredMenuElementOrder = .fixed
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.delegate = self
        collectionView.contentInset.top = 24
        collectionView.backgroundColor = .background
        return collectionView
    }()

    private let emptyView = EmptyView(type: .folderView)

    private let emptyAddButton: UIButton = {
        let button = UIButton()
        button.setImage(.addButtonBlue, for: .normal)
        button.setImage(.addButtonBlue, for: .highlighted)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        button.isHidden = true
        return button
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(title: String) {
        navigationView.setTitle(title)
    }

    func setDisplay(folders: [FolderDisplay], clips: [ClipDisplay]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        if !folders.isEmpty {
            let folderItems = folders.map { Item.folder($0) }
            snapshot.appendSections([.folder])
            snapshot.appendItems(folderItems, toSection: .folder)
        }

        if !clips.isEmpty {
            let clipItems = clips.map { Item.clip($0) }
            snapshot.appendSections([.clip])
            snapshot.appendItems(clipItems, toSection: .clip)
        }

        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    func setDisplay(isHidden: Bool) {
        emptyView.isHidden = isHidden
        emptyAddButton.isHidden = isHidden
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

private extension FolderView {
    func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { index, env in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.showsSeparators = false
            config.backgroundColor = .background
            config.headerMode = .supplementary
            config.headerTopPadding = 0
            config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                let delete = UIContextualAction(
                    style: .destructive,
                    title: "삭제"
                ) { [weak self] _, _, completion in
                    self?.performAction(for: indexPath) {
                        .didTapDeleteButton($0, $1.displayTitle)
                    }
                    completion(true)
                }

                delete.image = .trashWhite
                delete.backgroundColor = .red600

                return UISwipeActionsConfiguration(actions: [delete])
            }

            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
            section.boundarySupplementaryItems = [self.makeHeaderItemLayout()]
            section.interGroupSpacing = 8
            if let sectionKind = self.dataSource?.sectionIdentifier(for: index) {
                switch sectionKind {
                case .folder:
                    section.contentInsets = .init(top: 8, leading: 0, bottom: 40, trailing: 24)
                case .clip:
                    section.contentInsets = .init(top: 8, leading: 0, bottom: 24, trailing: 24)
                }
            }
            return section
        }
        return layout
    }

    func makeHeaderItemLayout() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(48)
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
        return header
    }
}

extension FolderView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        .init(
            identifier: indexPath as NSCopying,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self,
                  let item = self.dataSource?.itemIdentifier(for: indexPath)
            else {
                return UIMenu()
            }

            let edit = self.makeEditAction(for: indexPath)
            let delete = self.makeDeleteAction(for: indexPath)

            switch item {
            case .clip:
                let detail = self.makeDetailAction(for: indexPath)
                return UIMenu(title: "", children: [detail, edit, delete])
            case .folder:
                return UIMenu(title: "", children: [edit, delete])
            }
        }
    }
}

private extension FolderView {
    func makeAddButtonMenu() -> UIMenu {
        let addFolderAction = UIAction(
            title: "폴더 추가",
            image: .folderPlus.withTintColor(.textPrimary)
        ) { [weak self] _ in
            self?.action.accept(.didTapAddFolderButton)
        }

        let addClipAction = UIAction(
            title: "클립 추가",
            image: .clip.withTintColor(.textPrimary)
        ) { [weak self] _ in
            self?.action.accept(.didTapAddClipButton)
        }

        return UIMenu(title: "", children: [addFolderAction, addClipAction])
    }

    func makeDetailAction(for indexPath: IndexPath) -> UIAction {
        .init(
            title: "상세정보",
            image: .info.withTintColor(.textPrimary)
        ) { [weak self] _ in
            self?.performAction(for: indexPath) { .didTapDetailButton($0) }
        }
    }

    func makeEditAction(for indexPath: IndexPath) -> UIAction {
        .init(
            title: "편집",
            image: .pen.withTintColor(.textPrimary)
        ) { [weak self] _ in
            self?.performAction(for: indexPath) { .didTapEditButton($0) }
        }
    }

    func makeDeleteAction(for indexPath: IndexPath) -> UIAction {
        .init(
            title: "삭제",
            image: .trashRed,
            attributes: .destructive
        ) { [weak self] _ in
            self?.performAction(for: indexPath) {
                .didTapDeleteButton($0, $1.displayTitle)
            }
        }
    }
}

private extension FolderView {
    func performAction(
        for indexPath: IndexPath,
        transform: (IndexPath, Item) -> Action
    ) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        let logical = logicalIndexPath(indexPath)
        action.accept(transform(logical, item))
    }

    func performAction(
        for indexPath: IndexPath,
        transform: (IndexPath) -> Action
    ) {
        let logical = logicalIndexPath(indexPath)
        action.accept(transform(logical))
    }

    func logicalIndexPath(_ indexPath: IndexPath) -> IndexPath {
        guard let section = self.dataSource?.sectionIdentifier(for: indexPath.section)
        else { return indexPath }

        return section.logicalIndexPath(for: indexPath.item)
    }
}

private extension FolderView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
        setDataSource()
    }

    func setAttributes() {
        navigationView.setLeftItem(backButton)

        addButton.menu = makeAddButtonMenu()
        addButton.showsMenuAsPrimaryAction = true

        backgroundColor = .background
    }

    func setHierarchy() {
        [navigationView, collectionView, emptyView, emptyAddButton, activityIndicator, addButton].forEach {
            addSubview($0)
        }
    }

    func setConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.size.equalTo(48)
        }

        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(24)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(291)
            make.height.equalTo(146)
            make.centerX.equalToSuperview()
        }

        emptyAddButton.snp.makeConstraints { make in
            make.top.equalTo(emptyView.snp.bottom).offset(32)
            make.width.equalTo(160)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func setDataSource() {
        let clipCellRegistration = UICollectionView.CellRegistration<ClipListCell, ClipDisplay> { cell, _, item in
            cell.setDisplay(item)
        }

        let folderCellRegistration = UICollectionView.CellRegistration<FolderListCell, FolderDisplay> { cell, _, item in
            cell.setDisplay(item)
        }

        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .clip(let clipItem):
                return collectionView.dequeueConfiguredReusableCell(
                    using: clipCellRegistration,
                    for: indexPath,
                    item: clipItem
                )
            case .folder(let folderItem):
                return collectionView.dequeueConfiguredReusableCell(
                    using: folderCellRegistration,
                    for: indexPath,
                    item: folderItem
                )
            }
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<CollectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, indexPath in
            guard
                let self,
                let section = dataSource?.sectionIdentifier(for: indexPath.section)
            else { return }

            switch section {
            case .clip:
                header.setTitle("클립")
            case .folder:
                header.setTitle("폴더")
            }
        }

        dataSource?.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }
    }

    func setBindings() {
        backButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] _ in
                guard let self else { return }
                action.accept(.didTapBackButton)
            }
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] indexPath in
                guard let self else { return }
                action.accept(.didTapCell(logicalIndexPath(indexPath)))
            }
            .disposed(by: disposeBag)

        emptyAddButton.rx.tap
            .map { Action.didTapAddClipButton }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
