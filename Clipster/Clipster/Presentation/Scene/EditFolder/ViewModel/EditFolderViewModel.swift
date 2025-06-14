import Foundation
import RxRelay
import RxSwift

enum EditFolderMode {
    case add(parentFolder: Folder?)
    case edit(parentFolder: Folder?, folder: Folder)
}

enum EditFolderAction {
    case folderTitleChanged(String)
    case saveButtonTapped
    case folderViewTapped
    case saveSucceeded(Folder)
    case saveFailed(Error)
    case selectFolder(selected: Folder?)
    case folderSelectorDismissed
}

struct EditFolderState {
    let mode: EditFolderMode
    var folderTitle: String
    let initialFolderTitle: String
    let navigationTitle: String
    var didFinishAddtion: Folder?
    var parentFolder: Folder?
    var parentFolderDisplay: FolderDisplay?

    var folderTitleLimit: String {
        "\(folderTitle.count) / 10"
    }

    var folder: Folder? {
        switch mode {
        case .add:
            return nil
        case .edit(_, let folder):
            return folder
        }
    }

    var isSavable: Bool {
        let trimmed = folderTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return false
        }

        switch mode {
        case .add:
            return true
        case .edit(_, let initialFolder):
            let isTitleChanged = trimmed != initialFolderTitle
            let isParentChanged = initialFolder.parentFolderID != parentFolder?.id
            return isTitleChanged || isParentChanged
        }
    }

    var shouldNavigateToFolderSelector = false
    var isProcessing = false
    var shouldDismiss = false
    var alertMessage: String?

    init(mode: EditFolderMode) {
        self.mode = mode
        switch mode {
        case .add(let parentFolder):
            self.folderTitle = ""
            self.initialFolderTitle = ""
            self.navigationTitle = "폴더 추가"
            self.parentFolder = parentFolder
            self.parentFolderDisplay = parentFolder.map { FolderDisplayMapper.map($0) }
        case .edit(let parentFolder, let folder):
            self.folderTitle = folder.title
            self.initialFolderTitle = folder.title
            self.navigationTitle = "폴더 편집"
            self.parentFolder = parentFolder
            self.parentFolderDisplay = parentFolder.map { FolderDisplayMapper.map($0) }
        }
    }
}

final class EditFolderViewModel {
    private let createFolderUseCase: CreateFolderUseCase
    private let updateFolderUseCase: UpdateFolderUseCase
    private let disposeBag = DisposeBag()

    private let stateRelay: BehaviorRelay<EditFolderState>

    let action = PublishRelay<EditFolderAction>()
    let state: Observable<EditFolderState>

    init(
        createFolderUseCase: CreateFolderUseCase,
        updateFolderUseCase: UpdateFolderUseCase,
        mode: EditFolderMode
    ) {
        self.createFolderUseCase = createFolderUseCase
        self.updateFolderUseCase = updateFolderUseCase

        let initialState = EditFolderState(mode: mode)
        self.stateRelay = BehaviorRelay(value: initialState)
        self.state = self.stateRelay.asObservable()

        action
            .do { action in
                print("\(Self.self): received action → \(action)")
            }
            .scan(initialState) { state, action in
                var newState = state
                newState.alertMessage = nil

                switch action {
                case .folderTitleChanged(let title):
                    print("\(Self.self): folder title changed to '\(title)'")
                    newState.folderTitle = title
                case .saveButtonTapped:
                    if newState.isSavable {
                        print("\(Self.self): save button tapped")
                        newState.isProcessing = true
                    }
                case .folderViewTapped:
                    print("\(Self.self): folder view tapped")
                    newState.shouldNavigateToFolderSelector = true
                case .saveSucceeded(let folder):
                    print("\(Self.self): save succeeded")
                    newState.isProcessing = false
                    newState.shouldDismiss = true

                    if case .add = newState.mode {
                        newState.didFinishAddtion = folder
                    }
                case .saveFailed(let error):
                    print("\(Self.self): save failed with error: \(error.localizedDescription)")
                    newState.isProcessing = false
                    newState.alertMessage = error.localizedDescription
                case .selectFolder(let selected):
                    print("\(Self.self): selected folder  \(selected?.title ?? "home")")
                    newState.parentFolder = selected
                    if let selected {
                        newState.parentFolderDisplay = FolderDisplayMapper.map(selected)
                    } else {
                        newState.parentFolderDisplay = nil
                    }
                case .folderSelectorDismissed:
                    print("\(Self.self): folder selector dismissed")
                    newState.shouldNavigateToFolderSelector = false
                }

                return newState
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)

        action
            .filter { if case .saveButtonTapped = $0 { return true } else { return false } }
            .withLatestFrom(stateRelay)
            .filter { $0.isSavable }
            .flatMapLatest { currentState in
                let title = currentState.folderTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let date = Date()

                var newFolder: Folder
                let useCase: (Folder) async -> Result<Void, DomainError>

                switch currentState.mode {
                case .add:
                    print("\(Self.self): attempting to add folder '\(title)' to parent '\(currentState.parentFolder?.title ?? "root")'")

                    newFolder = Folder(
                        id: UUID(),
                        parentFolderID: currentState.parentFolder?.id,
                        title: title,
                        depth: (currentState.parentFolder?.depth ?? -1) + 1,
                        folders: [],
                        clips: [],
                        createdAt: date,
                        updatedAt: date,
                        deletedAt: nil
                    )

                    useCase = self.createFolderUseCase.execute
                case .edit(_, let folder):
                    print("\(Self.self): attempting to edit folder \(folder.id) set title to '\(title)', parent to '\(currentState.parentFolder?.title ?? "root")'")

                    newFolder = Folder(
                        id: folder.id,
                        parentFolderID: currentState.parentFolder?.id,
                        title: title,
                        depth: (currentState.parentFolder?.depth ?? -1) + 1,
                        folders: folder.folders,
                        clips: folder.clips,
                        createdAt: folder.createdAt,
                        updatedAt: date,
                        deletedAt: folder.deletedAt
                    )

                    useCase = self.updateFolderUseCase.execute
                }

                return Observable<EditFolderAction>.create { observer in
                    Task {
                        let result = await useCase(newFolder)
                        switch result {
                        case .success:
                            observer.onNext(.saveSucceeded(newFolder))
                        case .failure(let error):
                            observer.onNext(.saveFailed(error))
                        }
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
