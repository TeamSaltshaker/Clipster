import Foundation
import RxRelay
import RxSwift

final class FolderViewModel {
    enum Action {
        case viewWillAppear
        case didTapCell(IndexPath)
        case didTapAddFolderButton
        case didTapAddClipButton
        case didTapDetailButton(IndexPath)
        case didTapEditButton(IndexPath)
        case didTapDeleteButton(IndexPath)
    }

    struct State {
        let currentFolderTitle: String
        let folders: [FolderDisplay]
        let clips: [ClipDisplay]
        let isEmptyViewHidden: Bool
    }

    enum Navigation {
        case editClipViewForAdd(Folder)
        case editClipViewForEdit(Clip)
        case editFolderView(Folder, Folder?)
        case folderView(Folder)
        case clipDetailView(Clip)
        case webView(URL)
    }

    var action = PublishRelay<Action>()
    var state: BehaviorRelay<State>
    var navigation = PublishRelay<Navigation>()
    var disposeBag = DisposeBag()

    private var folder: Folder
    private let fetchFolderUseCase: FetchFolderUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase
    private let updateClipUseCase: UpdateClipUseCase
    private let deleteClipUseCase: DeleteClipUseCase

    init(
        folder: Folder,
        fetchFolderUseCase: FetchFolderUseCase,
        deleteFolderUseCase: DeleteFolderUseCase,
        updateClipUseCase: UpdateClipUseCase,
        deleteClipUseCase: DeleteClipUseCase,
    ) {
        self.folder = folder
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        self.updateClipUseCase = updateClipUseCase
        self.deleteClipUseCase = deleteClipUseCase

        state = BehaviorRelay(value: State(
            currentFolderTitle: folder.title,
            folders: folder.folders.map { FolderDisplayMapper.map($0) },
            clips: folder.clips.map { ClipDisplayMapper.map($0) },
            isEmptyViewHidden: !folder.folders.isEmpty || !folder.clips.isEmpty,
        ))
        setBindings()
    }
}

private extension FolderViewModel {
    func setBindings() {
        action
            .skip(1)
            .subscribe { [weak self] action in
                guard let self else { return }
                print("\(Self.self): \(action)")

                switch action {
                case .viewWillAppear:
                    reloadFolder()
                case .didTapCell(let indexPath):
                    switch indexPath.section {
                    case 0:
                        navigateToFolderView(at: indexPath.item)
                    case 1:
                        updateLastVisitedDate(at: indexPath.item)
                        navigateToWebView(at: indexPath.item)
                    default:
                        break
                    }
                case .didTapAddClipButton:
                    navigateToAddClipView()
                case .didTapAddFolderButton:
                    navigateToAddFolderView()
                case .didTapDetailButton(let indexPath):
                    navigateToDetailView(at: indexPath)
                case .didTapEditButton(let indexPath):
                    navigateToEditView(at: indexPath)
                case .didTapDeleteButton(let indexPath):
                    delete(at: indexPath)
                }
            }
            .disposed(by: disposeBag)
    }

    func reloadFolder() {
        print("\(Self.self): reloadFolder() called")
        Task {
            guard case let .success(folder) = await fetchFolderUseCase.execute(id: folder.id) else {
                print("\(Self.self): Failed to reload")
                return
            }

            self.folder = folder
            state.accept(.init(
                currentFolderTitle: folder.title,
                folders: folder.folders.map(FolderDisplayMapper.map),
                clips: folder.clips.map(ClipDisplayMapper.map),
                isEmptyViewHidden: !folder.folders.isEmpty || !folder.clips.isEmpty,
            ))
        }
    }

    func updateLastVisitedDate(at index: Int) {
        Task {
            let clip = folder.clips[index]
            let updatedClip = Clip(
                id: clip.id,
                folderID: clip.folderID,
                urlMetadata: clip.urlMetadata,
                memo: clip.memo,
                lastVisitedAt: Date.now,
                createdAt: clip.createdAt,
                updatedAt: Date.now,
                deletedAt: clip.deletedAt,
            )
            _ = await updateClipUseCase.execute(clip: updatedClip)
        }
    }

    func navigateToWebView(at index: Int) {
        let url = folder.clips[index].urlMetadata.url
        navigation.accept(.webView(url))
    }

    func navigateToFolderView(at index: Int) {
        let folder = folder.folders[index]
        navigation.accept(.folderView(folder))
    }

    func navigateToAddClipView() {
        navigation.accept(.editClipViewForAdd(folder))
    }

    func navigateToAddFolderView() {
        navigation.accept(.editFolderView(folder, nil))
    }

    func navigateToDetailView(at indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let selectedClip = folder.clips[indexPath.item]
            navigation.accept(.clipDetailView(selectedClip))
        default:
            break
        }
    }

    func navigateToEditView(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let selectedFolder = folder.folders[indexPath.item]
            navigation.accept(.editFolderView(folder, selectedFolder))
        case 1:
            let selectedClip = folder.clips[indexPath.item]
            navigation.accept(.editClipViewForEdit(selectedClip))
        default:
            break
        }
    }

    func delete(at indexPath: IndexPath) {
        Task {
            switch indexPath.section {
            case 0:
                let folder = folder.folders[indexPath.item]
                _ = await deleteFolderUseCase.execute(folder)
            case 1:
                let clip = folder.clips[indexPath.item]
                _ = await deleteClipUseCase.execute(clip)
            default:
                break
            }
            reloadFolder()
        }
    }
}
