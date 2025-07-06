import RxRelay
import RxSwift
import SnapKit
import UIKit

final class TabBarView: UIView {
    enum Action {
        case tapHome
        case tapSearch
        case tapUser
    }

    private let disposeBag = DisposeBag()
    let action = PublishRelay<Action>()

    private let baseBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .cell
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private let homeContainer = UIView()
    private let searchContainer = UIView()
    private let userContainer = UIView()

    private let homeButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage.home
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.textPrimary)
        let selectedImage = UIImage.home
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.appPrimary)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        return button
    }()

    private lazy var searchButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage.search
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.textPrimary)
        let selectedImage = UIImage.search
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.appPrimary)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        return button
    }()

    private let userButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage.user
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.textPrimary)
        let selectedImage = UIImage.user
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.appPrimary)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
        )
        layer.shadowPath = path.cgPath
    }

    func updateSelectedTab(_ mode: TabBarMode) {
        [
            homeButton,
            searchButton,
            userButton
        ].enumerated().forEach { index, button in
            button.isSelected = (index == mode.rawValue)
        }
    }
}

private extension TabBarView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    func setAttributes() {
        backgroundColor = .background
        layer.cornerRadius = 32
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowRadius = 7
        layer.masksToBounds = false
    }

    func setHierarchy() {
        [
            baseBackgroundView,
            stackView
        ].forEach { addSubview($0) }

        [
            homeContainer,
            searchContainer,
            userContainer
        ].forEach { stackView.addArrangedSubview($0) }

        homeContainer.addSubview(homeButton)
        searchContainer.addSubview(searchButton)
        userContainer.addSubview(userButton)
    }

    func setConstraints() {
        baseBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        homeButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(64)
        }

        searchButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(64)
        }

        userButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(64)
        }
    }

    func setBindings() {
        Observable.merge(
            homeButton.rx.tap.map { Action.tapHome },
            searchButton.rx.tap.map { Action.tapSearch },
            userButton.rx.tap.map { Action.tapUser }
        )
        .bind(to: action)
        .disposed(by: disposeBag)
    }
}
