import RxCocoa
import RxSwift
import UIKit

final class EditClipViewController: UIViewController {
    private let viewModel: EditClipViewModel
    private let diContainer: DIContainer
    private let disposeBag = DisposeBag()

    private let editClipView = EditClipView()

    init(viewModel: EditClipViewModel, diContainer: DIContainer) {
        self.viewModel = viewModel
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = editClipView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        hideKeyboardWhenTappedBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

private extension EditClipViewController {
    func configure() {
        setAttributes()
        setBindings()
    }

    func setAttributes() {
        view.backgroundColor = .white800
    }

    func setBindings() {
        viewModel.state
            .map(\.urlInputText)
            .take(1)
            .asDriver(onErrorJustReturn: "")
            .drive(editClipView.urlInputTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.memoText)
            .take(1)
            .asDriver(onErrorJustReturn: "")
            .drive(editClipView.memoView.memoTextView.rx.text)
            .disposed(by: disposeBag)

        viewModel.state
            .compactMap(\.clip)
            .take(1)
            .subscribe { [weak self] _ in
                self?.viewModel.action.accept(.fetchFolder)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map { $0.type == .shareExtension }
            .filter { $0 }
            .take(1)
            .subscribe { [weak self] _ in
                self?.viewModel.action.accept(.fetchTopLevelFolder)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.navigationTitle)
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] in
                self?.editClipView.commonNavigationView.setTitle($0)
            }
            .disposed(by: disposeBag)

        editClipView.urlInputTextField
            .rx
            .text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe { [weak self] in
                self?.viewModel.action.accept(.editURLInputTextField($0))
            }
            .disposed(by: disposeBag)

        editClipView.urlInputTextField
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .subscribe { [weak self] _ in
                self?.viewModel.action.accept(.editingURLTextField)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.urlTextFieldBorderColor)
            .map { UIColor(resource: $0).cgColor }
            .asDriver(onErrorDriveWith: .empty())
            .drive(editClipView.urlInputTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.isHiddenURLMetadataStackView)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isHidden in
                self?.editClipView.urlMetadataStackView.setHiddenAnimated(isHidden)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.isHiddenURLValidationStackView)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isHidden in
                self?.editClipView.urlValidationStacKView.setHiddenAnimated(isHidden)
            }
            .disposed(by: disposeBag)

        editClipView.memoView.memoTextView
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] in
                self?.viewModel.action.accept(.editMomo($0))
            }
            .disposed(by: disposeBag)

        editClipView.memoView.memoTextView
            .rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .map { String($0.prefix(100)) }
            .asDriver(onErrorJustReturn: "")
            .drive(editClipView.memoView.memoTextView.rx.text)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.memoLimit)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "0 / 100")
            .drive(editClipView.memoView.memoLimitLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.state
            .map { state in
                if let imageName = state.urlValidationImageName {
                    return UIImage(named: imageName)
                } else {
                    return .none
                }
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .none)
            .drive(editClipView.urlValidationStacKView.statusImageView.rx.image)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.urlValidationLabelText)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive(editClipView.urlValidationStacKView.statusLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.urlMetadata)
            .compactMap { $0 }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] urlMetadataDisplay in
                self?.editClipView.urlMetadataStackView.setDisplay(model: urlMetadataDisplay)
            }
            .disposed(by: disposeBag)

        Observable.combineLatest(
            viewModel.state.map(\.clip),
            viewModel.state.map(\.memoText),
            viewModel.state.map(\.isURLValid),
            viewModel.state.map(\.currentFolder),
            viewModel.state.map(\.isLoading),
            viewModel.state.map(\.urlInputText)
        )
        .map { clip, memoText, isURLValid, currentFolder, isLoading, urlText in
            guard !isLoading else { return false }
            guard isURLValid else { return false }
            if let clip = clip {
                return clip.memo != memoText || currentFolder?.id != clip.folderID || clip.urlMetadata.url.absoluteString != urlText
            } else {
                return currentFolder != nil
            }
        }
        .distinctUntilChanged()
        .asDriver(onErrorDriveWith: .empty())
        .drive(editClipView.saveButton.rx.isEnabled)
        .disposed(by: disposeBag)

        editClipView.addFolderButton
            .rx
            .tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                let vm = diContainer.makeEditFolderViewModel(mode: .add(parentFolder: viewModel.state.value.currentFolder))
                let vc = EditFolderViewController(
                    viewModel: vm,
                    diContainer: diContainer
                )

                vc.onAdditionComplete = {
                    self.viewModel.action.accept(.editFolder($0))
                }

                navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)

        editClipView.backButton
            .rx
            .tap
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map { ($0.isFolderViewTapped, $0.currentFolder) }
            .filter { $0 && $1 != nil }
            .map { $1 }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] currentFolder in
                guard let self else { return }

                let vm = self.diContainer.makeFolderSelectorViewModel(mode: .editClip(parentFolder: currentFolder))
                let vc = FolderSelectorViewController(viewModel: vm, diContainer: self.diContainer)
                vc.onSelectionComplete = {
                    self.viewModel.action.accept(.editFolder($0))
                }
                vc.modalPresentationStyle = .pageSheet

                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [.custom { context in context.maximumDetentValue * 0.75 }]
                    sheet.prefersGrabberVisible = true
                }

                present(vc, animated: true)
                self.viewModel.action.accept(.folderSelectorViewDisappeared)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .compactMap(\.currentFolder)
            .distinctUntilChanged { $0.id == $1.id }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] in
                self?.editClipView.folderRowView.setDisplay(
                    FolderDisplayMapper.map($0)
                )
            }
            .disposed(by: disposeBag)

        editClipView.folderViewTapGesture
            .rx
            .event
            .subscribe { [weak self] _ in
                self?.viewModel.action.accept(.folderViewTapped)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.isSuccessfullyEdited)
            .filter { $0 }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        editClipView.saveButton
            .rx
            .tap
            .subscribe { [weak self] _ in
                self?.viewModel.action.accept(.saveClip)
            }
            .disposed(by: disposeBag)

        viewModel.state
            .map { $0.currentFolder == nil }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive(editClipView.folderView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.state
            .map { $0.currentFolder != nil }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive(editClipView.emptyView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.state
            .map(\.isLoading)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] isLoading in
                if isLoading {
                    self?.editClipView.urlValidationStacKView.activityIndicatorView.startAnimating()
                } else {
                    self?.editClipView.urlValidationStacKView.activityIndicatorView.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
    }
}

extension EditClipViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
