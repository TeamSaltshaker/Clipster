import SnapKit
import UIKit

final class SearchView: UIView {
    let searchTextField = SearchTextField()

    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    let emptyView: EmptyView = {
        let view = EmptyView(type: .searchView)
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCollecrtionViewLayout(layout: UICollectionViewLayout) {
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

private extension SearchView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
    }

    func setAttributes() {
        backgroundColor = .background
    }

    func setHierarchy() {
        [searchTextField, collectionView, emptyView]
            .forEach { addSubview($0) }
    }

    func setConstraints() {
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(4)
            make.directionalHorizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(20)
            make.directionalHorizontalEdges.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
