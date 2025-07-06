import SnapKit
import UIKit

final class OnboardingViewController: UIViewController {
    typealias Section = Int
    typealias Item = OnboardingItem

    var onFinish: (() -> Void)?

    private var items: [OnboardingItem] = [
        .init(
            image: .onboardingAdd,
            title: "추가하기",
            description: "추가하기 버튼을 이용해서\n폴더와 클립을 추가할 수 있어요."
        ),
        .init(
            image: .onboardingUnvisited,
            title: "방문하지 않은 클립",
            description: "방문하지 않은 클립을\n홈화면에서 확인할 수 있습니다."
        ),
        .init(
            image: .onboardingLongTap,
            title: "롱탭 기능",
            description: "롱탭을 이용해서 상세정보, 편집,\n그리고 삭제를 할 수 있습니다."
        ),
        .init(
            image: .onboardingFolder,
            title: "하위 폴더 기능",
            description: "자료는 하위 폴더로 정리해서 저장하고,\n필요할 때는 한 번에 쉽게 찾아보세요."
        ),
        .init(
            image: .onboardingValidation,
            title: "URL 적합성 검사 기능",
            description: "적합성 검사를 통해서 저장을 확실하게!"
        ),
        .init(
            image: .onboardingShare,
            title: "공유 버튼으로 클립 추가하기",
            description: "다른 앱에서 링크를 공유하면\n담담에 바로 저장할 수 있어요."
        )
    ]

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?

    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.blue600, for: .normal)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = .pretendard(size: 14, weight: .medium)
        button.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .blue600
        pageControl.pageIndicatorTintColor = .blue900
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureDataSource()
        applySnapshot()
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<
            OnboardingCell,
            Item
        > { cell, _, item in
            cell.setDisplay(item)
        }

        dataSource = .init(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.visibleItemsInvalidationHandler = { _, offset, env in
            let index = Int((offset.x / env.container.contentSize.width).rounded())
            self.pageControl.currentPage = index
        }
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, OnboardingItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    @objc
    private func didTapStart() {
        onFinish?()
    }
}

private extension OnboardingViewController {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        view.backgroundColor = .background
    }

    func setHierarchy() {
        [
            skipButton,
            collectionView,
            pageControl
        ].forEach { view.addSubview($0) }
    }

    func setConstraints() {
        skipButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(14)
            make.trailing.equalToSuperview().inset(24)
        }

        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.height.equalTo(8)
            make.centerX.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(skipButton.snp.bottom).offset(14)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(pageControl.snp.top).offset(-24)
        }
    }
}
