import RxRelay
import RxSwift
import SnapKit
import UIKit

final class SavePathOptionSelectorView: UIView {
    enum Action {
        case tapView(SavePathOption)
    }

    let action = PublishRelay<Action>()
    private let disposeBag = DisposeBag()

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
        label.text = "저장 경로 보기"
        label.font = .pretendard(size: 16, weight: .semiBold)
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .textTertiary
        return view
    }()

    private let accordionRadioView = SavePathLayoutRadioImageView()
    private let directoryRadioView = SavePathLayoutRadioImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplay(option: SavePathOption) {
        let isAccordion: Bool
        switch option {
        case .expand:
            isAccordion = true
        case .skip:
            isAccordion = false
        }

        accordionRadioView.setDisplay(
            title: "펼치기",
            isSelected: isAccordion,
            previewImage: .savePathLayoutAccordion
        )

        directoryRadioView.setDisplay(
            title: "넘기기",
            isSelected: !isAccordion,
            previewImage: .savePathLayoutDirectory
        )
    }
}

private extension SavePathOptionSelectorView {
    func configure() {
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    func setAttributes() {
        backgroundColor = .background
    }

    func setHierarchy() {
        [
            baseBackgroundView,
            grabberView,
            titleLabel,
            separatorView,
            accordionRadioView,
            directoryRadioView
        ].forEach { addSubview($0) }
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

        accordionRadioView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalTo(self.snp.centerX).offset(-5.5)
            make.bottom.equalToSuperview()
        }

        directoryRadioView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(self.snp.centerX).offset(5.5)
            make.bottom.equalToSuperview()
        }
    }

    func setBindings() {
        let accordionTap = UITapGestureRecognizer()
        accordionRadioView.addGestureRecognizer(accordionTap)
        accordionTap.rx.event
            .map { _ in Action.tapView(.expand) }
            .bind(to: action)
            .disposed(by: disposeBag)

        let directoryTap = UITapGestureRecognizer()
        directoryRadioView.addGestureRecognizer(directoryTap)
        directoryTap.rx.event
            .map { _ in Action.tapView(.skip) }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
