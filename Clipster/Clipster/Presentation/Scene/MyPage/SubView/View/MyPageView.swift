import RxRelay
import RxSwift
import SnapKit
import UIKit

class MyPageView: UIView {
    typealias Section = MyPageSection
    typealias Item = MyPageItem

    enum Action {
        case tapCell(MyPageItem)
    }

    private var disposeBag = DisposeBag()
    let action = PublishRelay<Action>()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?

    private let navigationView: CommonNavigationView = {
        let view = CommonNavigationView()
        view.setTitle("마이 페이지")
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.contentInset.top = 24
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configureDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(_ sections: [MyPageSectionModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        sections.forEach {
            snapshot.appendSections([$0.section])
            snapshot.appendItems($0.items, toSection: $0.section)
        }
        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    func scrollToTop(animated: Bool) {
        collectionView.setContentOffset(.zero, animated: animated)
    }

    func showLoading() {
        loadingIndicator.startAnimating()
        isUserInteractionEnabled = false
    }

    func hideLoading() {
        loadingIndicator.stopAnimating()
        isUserInteractionEnabled = true
    }
}

private extension MyPageView {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let backgroundKind = "BackgroundView"

        let layout = UICollectionViewCompositionalLayout { [weak self] index, _ in
            guard let self,
                  let sectionKind = dataSource?.sectionIdentifier(for: index),
                  let items = dataSource?.snapshot().itemIdentifiers(inSection: sectionKind)
            else { return nil }
            switch sectionKind {
            case .login, .welcome:
                return makeLoginSectionLayout(items: items)
            case .etc:
                return makeAccountSectionLayout(items: items)
            default:
                return makeSettingSectionsLayout(
                    items: items,
                    backgroundKind: backgroundKind
                )
            }
        }
        layout.register(SettingSectionBackgroundView.self, forDecorationViewOfKind: backgroundKind)
        return layout
    }

    func makeLoginSectionLayout(items: [MyPageItem]) -> NSCollectionLayoutSection {
        let itemHeight: CGFloat = 48
        let itemSpacing: CGFloat = 16

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let totalSpacing = CGFloat(max(0, items.count - 1)) * itemSpacing
        let rawHeight = CGFloat(items.count) * itemHeight + totalSpacing
        let groupHeight = max(1, rawHeight)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(groupHeight)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(itemSpacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 18, bottom: 24, trailing: 18)
        section.boundarySupplementaryItems = [makeHeaderItemLayout()]
        return section
    }

    func makeAccountSectionLayout(items: [MyPageItem]) -> NSCollectionLayoutSection {
        let defaultHeight: CGFloat = 68
        let versionHeight: CGFloat = 92

        let subitems: [NSCollectionLayoutItem] = items.map { item in
            let height: CGFloat
            switch item {
            case .version:
                height = versionHeight
            default:
                height = defaultHeight
            }

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(height)
            )
            return NSCollectionLayoutItem(layoutSize: itemSize)
        }

        let rawHeight: CGFloat = items.reduce(0) { result, item in
            let height: CGFloat
            switch item {
            case .version:
                height = versionHeight
            default:
                height = defaultHeight
            }
            return result + height
        }
        let groupHeight = max(1, rawHeight)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(groupHeight)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: subitems
        )

        let section = NSCollectionLayoutSection(group: group)
        return section
    }

    func makeSettingSectionsLayout(items: [MyPageItem], backgroundKind: String) -> NSCollectionLayoutSection {
        let titleHeight: CGFloat = 17
        let defaultHeight: CGFloat = 48
        let spacing: CGFloat = 8

        let subitems: [NSCollectionLayoutItem] = items.map { item in
            let height: CGFloat = {
                if case .sectionTitle = item {
                    return titleHeight
                } else {
                    return defaultHeight
                }
            }()

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(height)
            )
            return NSCollectionLayoutItem(layoutSize: itemSize)
        }

        let rawHeight: CGFloat = items.reduce(0) { result, item in
            let height: CGFloat = {
                if case .sectionTitle = item {
                    return titleHeight
                } else {
                    return defaultHeight
                }
            }()
            return result + height
        }

        let groupHeight = max(1, rawHeight + CGFloat(max(0, items.count - 1)) * spacing)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(groupHeight)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: subitems
        )
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 40, bottom: 12, trailing: 40)

        let background = NSCollectionLayoutDecorationItem.background(elementKind: backgroundKind)
        background.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24)
        section.decorationItems = [background]
        return section
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
        return header
    }
}

private extension MyPageView {
    func configureDataSource() {
        let settingCellRegistration = UICollectionView.CellRegistration<
            SettingCell,
            MyPageItem
        > { cell, _, item in
            cell.setDisplay(item)
        }

        let loginCellRegistration = UICollectionView.CellRegistration<
            LoginCell,
            LoginType
        > { cell, _, item in
            cell.setDisplay(item)
        }

        let simpleCellRegistration = UICollectionView.CellRegistration<
            UICollectionViewListCell,
            MyPageItem
        > { cell, _, item in
            var config = cell.defaultContentConfiguration()

            config.text = item.titleText
            config.textProperties.color = item.titleColor
            config.textProperties.font = item.titleFont
            config.textProperties.alignment = .center

            if case .version = item {
                config.secondaryText = item.valueText
                config.secondaryTextProperties.color = item.valueColor
                config.secondaryTextProperties.font = item.valueFont
                config.secondaryTextProperties.alignment = .center
                config.textToSecondaryTextVerticalPadding = 10
            }

            cell.contentConfiguration = config
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<CollectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, indexPath in
            guard
                let self,
                let sectionKind = dataSource?.sectionIdentifier(for: indexPath.section)
            else { return }

            switch sectionKind {
            case .login, .welcome:
                header.setTitle(sectionKind.title)
                header.setTitleFont(size: 28, weight: .extraBold)
            default:
                break
            }
        }

        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .login(let loginType):
                return collectionView.dequeueConfiguredReusableCell(
                    using: loginCellRegistration,
                    for: indexPath,
                    item: loginType
                )
            case .account, .version:
                return collectionView.dequeueConfiguredReusableCell(
                    using: simpleCellRegistration,
                    for: indexPath,
                    item: item
                )
            default:
                return collectionView.dequeueConfiguredReusableCell(
                    using: settingCellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        }

        dataSource?.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }
    }
}

private extension MyPageView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    func setAttributes() {
        backgroundColor = .white800
    }

    func setHierarchy() {
        [
            navigationView,
            collectionView,
            loadingIndicator
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func setBindings() {
        collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath -> Action? in
                guard let self = self,
                      let item = dataSource?.itemIdentifier(for: indexPath)
                else { return nil }

                return Action.tapCell(item)
            }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
