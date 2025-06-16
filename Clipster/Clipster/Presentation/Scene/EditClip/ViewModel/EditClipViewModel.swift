import Foundation
import RxRelay
import RxSwift

final class EditClipViewModel: ViewModel {
    enum EditClipType {
        case edit
        case create
        case shareExtension
    }

    enum Action {
        case editURLInputTextField(String)
        case editingURLTextField
        case editMomo(String)
        case folderViewTapped
        case editFolder(Folder?)
        case saveClip
        case fetchFolder
        case fetchTopLevelFolder
        case folderSelectorViewDisappeared
    }

    enum Mutation {
        case updateURLInputText(String)
        case updateMemo(String)
        case updateValidURL(Bool)
        case updateURLMetadata(URLMetadataDisplay?)
        case updateFolderViewTapped(Bool)
        case updateCurrentFolder(Folder?)
        case updateSuccessfullyEdited(Bool)
        case updateIsLoading(Bool)
    }

    struct State {
        var type: EditClipType
        var urlInputText: String
        var isLoading = false
        var isHiddenURLMetadataStackView = true
        var isHiddenURLValidationStackView = true
        var memoText: String = ""
        var memoLimit: String = "0 / 100"
        var isURLValid = false
        var urlValidationImageName: String?
        var urlValidationLabelText: String = ""
        var urlMetadata: URLMetadataDisplay?
        var isFolderViewTapped: Bool = false
        var clip: Clip?
        var currentFolder: Folder?
        var isSuccessfullyEdited: Bool = false
        var urlTextFieldBorderColor: ColorResource = .black900
        var navigationTitle: String
    }

    var state: BehaviorRelay<State>
    var action = PublishRelay<Action>()
    var disposeBag = DisposeBag()

    private let checkURLValidityUseCase: CheckURLValidityUseCase
    private let parseURLMetadataUseCase: ParseURLMetadataUseCase
    private let fetchFolderUseCase: FetchFolderUseCase
    private let fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase
    private let createClipUseCase: CreateClipUseCase
    private let updateClipUseCase: UpdateClipUseCase

    init(
        urlText: String = "",
        currentFolder: Folder? = nil,
        checkURLValidityUseCase: CheckURLValidityUseCase,
        parseURLMetadataUseCase: ParseURLMetadataUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        createClipUseCase: CreateClipUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        state = BehaviorRelay(value: State(
            type: urlText.isEmpty ? .create : .shareExtension,
            urlInputText: urlText,
            currentFolder: currentFolder,
            navigationTitle: "클립 추가"
        ))
        self.checkURLValidityUseCase = checkURLValidityUseCase
        self.parseURLMetadataUseCase = parseURLMetadataUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.fetchTopLevelFoldersUseCase = fetchTopLevelFoldersUseCase
        self.createClipUseCase = createClipUseCase
        self.updateClipUseCase = updateClipUseCase
        bind()
    }

    init(
        clip: Clip,
        checkURLValidityUseCase: CheckURLValidityUseCase,
        parseURLMetadataUseCase: ParseURLMetadataUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        createClipUseCase: CreateClipUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        state = BehaviorRelay(value: State(
            type: .edit,
            urlInputText: clip.urlMetadata.url.absoluteString,
            memoText: clip.memo,
            memoLimit: "\(clip.memo.count) / 100",
            clip: clip,
            navigationTitle: "클립 수정"
        ))
        self.checkURLValidityUseCase = checkURLValidityUseCase
        self.parseURLMetadataUseCase = parseURLMetadataUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.fetchTopLevelFoldersUseCase = fetchTopLevelFoldersUseCase
        self.createClipUseCase = createClipUseCase
        self.updateClipUseCase = updateClipUseCase
        bind()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .editURLInputTextField(let urlText):
            let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
            print("\(Self.self) \(action)")
            return .merge(
                .just(.updateURLInputText(trimmed)),
                .fromAsync {
                    try await self.checkURLValidityUseCase.execute(urlString: trimmed).get()
                }
                .map { .updateValidURL($0) }
                .catchAndReturn(.updateValidURL(false)),
                .fromAsync {
                    try await self.parseURLMetadataUseCase.execute(urlString: trimmed).get()
                }
                .map { .updateURLMetadata(self.toURLMetaDisplay(entity: $0)) }
                .catchAndReturn(.updateURLMetadata(nil))
            )
        case .editingURLTextField:
            return .just(.updateIsLoading(true))
        case .editMomo(let memoText):
            print("\(Self.self) \(action)")
            return .just(.updateMemo(memoText))
        case .folderViewTapped:
            print("\(Self.self) \(action)")
            return .just(.updateFolderViewTapped(true))
        case .editFolder(let newFolder):
            print("\(Self.self) \(action)")
            return .just(.updateCurrentFolder(newFolder))
        case .saveClip:
            print("\(Self.self) \(action)")
            switch state.value.type {
            case .edit:
                print("\(Self.self) edit clip")
                guard let clip = state.value.clip else { return .empty() }
                guard let currentFolder = state.value.currentFolder else { return .empty() }
                guard let urlMetadata = state.value.urlMetadata else { return .empty() }

                let newClip = Clip(
                    id: clip.id,
                    folderID: currentFolder.id,
                    urlMetadata: URLMetadata(
                        url: urlMetadata.url,
                        title: urlMetadata.title,
                        thumbnailImageURL: urlMetadata.thumbnailImageURL,
                        createdAt: clip.createdAt,
                        updatedAt: clip.urlMetadata.url != urlMetadata.url ? Date() : clip.updatedAt,
                        deletedAt: clip.deletedAt
                    ),
                    memo: state.value.memoText,
                    lastVisitedAt: clip.lastVisitedAt,
                    createdAt: clip.createdAt,
                    updatedAt: clip.memo != state.value.memoText &&
                    clip.urlMetadata.url != urlMetadata.url &&
                    clip.folderID != currentFolder.id ? Date() : clip.updatedAt,
                    deletedAt: clip.deletedAt
                )
                return .fromAsync {
                    try await self.updateClipUseCase.execute(clip: newClip).get()
                }
                .map { .updateSuccessfullyEdited(true) }
                .catchAndReturn(.updateSuccessfullyEdited(false))
            case .create, .shareExtension:
                print("\(Self.self) save clip")
                guard let currentFolder = state.value.currentFolder else { return .empty() }
                guard let urlMetadata = state.value.urlMetadata else { return .empty() }

                let newClip = Clip(
                    id: UUID(),
                    folderID: currentFolder.id,
                    urlMetadata: URLMetadata(
                        url: urlMetadata.url,
                        title: urlMetadata.title,
                        thumbnailImageURL: urlMetadata.thumbnailImageURL,
                        createdAt: Date(),
                        updatedAt: Date(),
                        deletedAt: nil
                    ),
                    memo: state.value.memoText,
                    lastVisitedAt: nil,
                    createdAt: Date(),
                    updatedAt: Date(),
                    deletedAt: nil
                )
                return .fromAsync {
                    try await self.createClipUseCase.execute(newClip).get()
                }
                .map { .updateSuccessfullyEdited(true) }
                .catchAndReturn(.updateSuccessfullyEdited(false))
            }
        case .fetchFolder:
            print("\(Self.self) \(action)")
            guard let clip = state.value.clip else { return .empty() }
            return .fromAsync {
                try await self.fetchFolderUseCase.execute(id: clip.folderID).get()
            }
            .map { .updateCurrentFolder($0) }
            .catchAndReturn(.updateCurrentFolder(nil))
        case .fetchTopLevelFolder:
            print("\(Self.self) \(action)")
            return .fromAsync {
                try await self.fetchTopLevelFoldersUseCase.execute().get()
            }
            .map { $0.max { $0.updatedAt < $1.updatedAt } }
            .map { .updateCurrentFolder($0) }
            .catchAndReturn(.updateCurrentFolder(nil))
        case .folderSelectorViewDisappeared:
            print("\(Self.self) \(action)")
            return .just(.updateFolderViewTapped(false))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateURLInputText(let urlText):
            newState.urlInputText = urlText
            if urlText.isEmpty {
                newState.isHiddenURLValidationStackView = true
            }
        case .updateMemo(let memoText):
            newState.memoText = memoText
            newState.memoLimit = "\(memoText.count) / 100"
        case .updateValidURL(let result):
            newState.isURLValid = result
            newState.urlValidationImageName = result ? "CheckBlue" : "XRed"
            newState.urlValidationLabelText = result ? "올바른 URL 입니다." : "올바르지 않은 URL 입니다."
            newState.isLoading = false

            if !state.urlInputText.isEmpty {
                newState.isHiddenURLValidationStackView = false
            }

            if state.urlInputText.isEmpty {
                newState.urlTextFieldBorderColor = .black900
            } else {
                newState.urlTextFieldBorderColor = result ? .blue600 : .red600
            }
        case .updateURLMetadata(let urlMetaDisplay):
            newState.urlMetadata = urlMetaDisplay
            newState.isHiddenURLMetadataStackView = urlMetaDisplay == nil
        case .updateFolderViewTapped(let value):
            newState.isFolderViewTapped = value
        case .updateCurrentFolder(let newFolder):
            newState.currentFolder = newFolder
        case .updateSuccessfullyEdited(let value):
            newState.isSuccessfullyEdited = value
        case .updateIsLoading(let value):
            newState.isLoading = value
            newState.urlValidationLabelText = "URL 분석 중..."
            newState.urlValidationImageName = nil
        }
        return newState
    }
}

private extension EditClipViewModel {
    func toURLMetaDisplay(entity: ParsedURLMetadata) -> URLMetadataDisplay {
        URLMetadataDisplay(
            url: entity.url,
            title: entity.title,
            thumbnailImageURL: entity.thumbnailImageURL
        )
    }
}

extension Observable {
    static func fromAsync<T>(_ block: @escaping () async throws -> T) -> Observable<T> {
        Single.create { emitter in
            Task {
                do {
                    let result = try await block()
                    emitter(.success(result))
                } catch {
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
        .asObservable()
    }
}
