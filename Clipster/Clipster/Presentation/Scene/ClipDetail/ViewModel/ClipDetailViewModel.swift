import RxRelay
import RxSwift

enum ClipDetailAction {
    case viewWillAppear
    case editButtonTapped
    case deleteButtonTapped
    case deleteConfirmed
    case deleteCanceled
    case dataLoadSucceeded(clip: Clip, folder: Folder)
    case dataLoadFailed(Error)
    case deleteSucceeded
    case deleteFailed(Error)
}

struct ClipDetailState {
    var clip: Clip
    var clipDisplay: ClipDisplay
    var folder: Folder?
    let navigationTitle: String
    var isLoading = true
    var isProcessingDelete = false
    var shouldDismiss = false
    var shouldNavigateToEdit = false
    var showDeleteConfirmation = false
    var errorMessage: String?

    init(clip: Clip, navigationTitle: String) {
        self.clip = clip
        self.clipDisplay = ClipDisplayMapper.map(clip)
        self.navigationTitle = navigationTitle
    }
}

final class ClipDetailViewModel {
    private let fetchFolderUseCase: FetchFolderUseCase
    private let deleteClipUseCase: DeleteClipUseCase
    private let fetchClipUseCase: FetchClipUseCase

    private let disposeBag = DisposeBag()

    private let stateRelay: BehaviorRelay<ClipDetailState>

    let action = PublishRelay<ClipDetailAction>()
    let state: Observable<ClipDetailState>

    init(
        fetchFolderUseCase: FetchFolderUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        fetchClipUseCase: FetchClipUseCase,
        clip: Clip,
        navigationTitle: String
    ) {
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.fetchClipUseCase = fetchClipUseCase

        let initialState = ClipDetailState(clip: clip, navigationTitle: navigationTitle)
        self.stateRelay = BehaviorRelay(value: initialState)
        self.state = self.stateRelay.asObservable()

        let viewWillAppearStream = action
            .filter { if case .viewWillAppear = $0 { return true } else { return false } }
            .share()

        action
            .do { action in
                print("\(Self.self): received action → \(action)")
            }
            .scan(initialState) { state, action in
                var newState = state
                newState.errorMessage = nil
                newState.shouldNavigateToEdit = false

                switch action {
                case .viewWillAppear:
                    print("\(Self.self): viewWillAppear")
                    newState.isLoading = true
                case .editButtonTapped:
                    print("\(Self.self): edit button tapped")
                    newState.shouldNavigateToEdit = true
                case .deleteButtonTapped:
                    print("\(Self.self): delete button tapped")
                    newState.showDeleteConfirmation = true
                case .deleteConfirmed:
                    print("\(Self.self): delete confirmed")
                    newState.isProcessingDelete = true
                case .deleteCanceled:
                    print("\(Self.self): delete canceled")
                    newState.showDeleteConfirmation = false
                case .dataLoadSucceeded(let clip, let folder):
                    print("\(Self.self): data load succeeded with clip \(clip.id), folder \(folder.id)")
                    newState.isLoading = false
                    newState.clip = clip
                    newState.folder = folder
                    newState.clipDisplay = ClipDisplayMapper.map(clip)
                case .dataLoadFailed(let error):
                    print("\(Self.self): data load failed with error: \(error.localizedDescription)")
                    newState.isLoading = false
                    newState.errorMessage = "데이터를 가져오는데 실패했습니다."
                case .deleteSucceeded:
                    newState.isProcessingDelete = false
                    newState.shouldDismiss = true
                case .deleteFailed(let error):
                    print("\(Self.self): delete failed with error \(error.localizedDescription)")
                    newState.isProcessingDelete = false
                    newState.errorMessage = "삭제에 실패했습니다."
                }

                return newState
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)

        viewWillAppearStream
            .take(1)
            .flatMapLatest { [weak self] _ -> Observable<ClipDetailAction> in
                guard let self else { return .empty() }

                let clip = stateRelay.value.clip

                print("\(Self.self): fetching folder for clip \(clip.id)")
                return runAsyncTask {
                    await self.fetchFolderUseCase.execute(parentFolderID: clip.folderID)
                }
                .map {
                    print("\(Self.self): fetchFolderUseCase succeeded for folder \($0.id)")
                    return .dataLoadSucceeded(clip: clip, folder: $0)
                }
                .catch {
                    print("\(Self.self): fetchFolderUseCase failed with error: \($0.localizedDescription)")
                    return .just(.dataLoadFailed($0))
                }
                .asObservable()
            }
            .bind(to: action)
            .disposed(by: disposeBag)

        viewWillAppearStream
            .skip(1)
            .flatMapLatest { [weak self] _ -> Observable<ClipDetailAction> in
                guard let self else { return .empty() }

                let clipID = stateRelay.value.clip.id

                print("\(Self.self): fetching clip \(clipID)")
                return runAsyncTask {
                    await self.fetchClipUseCase.execute(id: clipID)
                }
                .flatMap { updatedClip in
                    print("\(Self.self): fetchClipUseCase succeeded for clip \(updatedClip.id)")

                    print("\(Self.self): fetching folder for clip \(updatedClip.id) in folder \(updatedClip.folderID)")
                    return self.runAsyncTask {
                        await self.fetchFolderUseCase.execute(parentFolderID: updatedClip.folderID)
                    }
                    .map { folder in
                        print("\(Self.self): fetchFolderUseCase succeeded for folder \(folder.id)")
                        return .dataLoadSucceeded(clip: updatedClip, folder: folder)
                    }
                }
                .catch {
                    print("\(Self.self): failed to load clip/folder with error: \($0.localizedDescription)")
                    return .just(.dataLoadFailed($0))
                }
                .asObservable()
            }
            .bind(to: action)
            .disposed(by: disposeBag)

        action
            .filter { if case .deleteConfirmed = $0 { return true } else { return false } }
            .withLatestFrom(stateRelay) { $1 }
            .flatMapLatest { [weak self] state -> Observable<ClipDetailAction> in
                guard let self else { return .empty() }

                let clipID = state.clip.id

                print("\(Self.self): attempting to delete clip \(clipID)")
                return runAsyncTask {
                    await self.deleteClipUseCase.execute(id: clipID)
                }
                .map {
                    print("\(Self.self): deleteClipUseCase succeeded")
                    return .deleteSucceeded
                }
                .catch {
                    print("\(Self.self): deleteClipUseCase failed with error: \($0.localizedDescription)")
                    return .just(.deleteFailed($0))
                }
                .asObservable()
            }
            .bind(to: action)
            .disposed(by: disposeBag)
    }

    private func runAsyncTask<T>(_ task: @escaping () async -> Result<T, Error>) -> Single<T> {
        Single.create { single in
            Task {
                switch await task() {
                case .success(let value):
                    single(.success(value))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
