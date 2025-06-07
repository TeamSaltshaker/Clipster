import Foundation
import RxRelay
import RxSwift

final class HomeViewModel {
    enum Action {
        case viewWillAppear
        case tapAddClip
        case tapAddFolder
        case tapCell(IndexPath)
        case tapDetail(IndexPath)
        case tapEdit(IndexPath)
        case tapDelete(IndexPath)
        case tapLicense
    }

    enum State {
        case homeDisplay(HomeDisplay)
    }

    enum Route {
        case showAddClip
        case showAddFolder
        case showWebView(URL)
        case showFolder(Folder)
        case showDetailClip(Clip)
        case showEditClip(Clip)
        case showEditFolder(Folder)
        case showLicense
    }

    private let disposeBag = DisposeBag()

    let action = PublishRelay<Action>()
    let state = PublishRelay<State>()
    let route = PublishRelay<Route>()

    private var unvisitedClips: [Clip] = []
    private var folders: [Folder] = []

    private let fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase
    private let fetchFolderUseCase: FetchFolderUseCase
    private let deleteClipUseCase: DeleteClipUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase

    init(
        fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        deleteFolderUseCase: DeleteFolderUseCase
    ) {
        self.fetchUnvisitedClipsUseCase = fetchUnvisitedClipsUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        bind()
    }

    private func bind() {
        action
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewWillAppear:
                    Task { await owner.makeHomeDisplay() }
                case .tapAddClip:
                    owner.route.accept(.showAddClip)
                case .tapAddFolder:
                    owner.route.accept(.showAddFolder)
                case .tapCell(let indexPath),
                     .tapDetail(let indexPath),
                     .tapEdit(let indexPath):
                    if let route = owner.route(for: action, at: indexPath) {
                        owner.route.accept(route)
                    }
                case .tapDelete(let indexPath):
                    owner.handleTapDelete(at: indexPath)
                case .tapLicense:
                    owner.route.accept(.showLicense)
                }
            }
            .disposed(by: disposeBag)
    }

    private func route(for action: Action, at indexPath: IndexPath) -> Route? {
        switch indexPath.section {
        case 0 where indexPath.item < unvisitedClips.count:
            let clip = unvisitedClips[indexPath.item]
            switch action {
            case .tapCell:
                return .showWebView(clip.urlMetadata.url)
            case .tapDetail:
                return .showDetailClip(clip)
            case .tapEdit:
                return .showEditClip(clip)
            default:
                return nil
            }
        case 1 where indexPath.item < folders.count:
            let folder = folders[indexPath.item]
            switch action {
            case .tapCell:
                return .showFolder(folder)
            case .tapEdit:
                return .showEditFolder(folder)
            default:
                return nil
            }
        default:
            return nil
        }
    }

    private func makeHomeDisplay() async {
        async let clipsResult = makeClipCellDisplays()
        async let foldersResult = makeFolderCellDisplays()

        do {
            let homeDisplay = try await HomeDisplay(
                unvitsedClips: clipsResult,
                folders: foldersResult
            )
            state.accept(.homeDisplay(homeDisplay))
        } catch {
            print(error)
        }
    }

    private func makeClipCellDisplays() async throws -> [ClipCellDisplay] {
        let clips = try await fetchUnvisitedClipsUseCase.execute().get()
        unvisitedClips = clips

        return clips.map {
            ClipCellDisplay(
                thumbnailImageURL: $0.urlMetadata.thumbnailImageURL,
                title: $0.urlMetadata.title,
                memo: $0.memo,
                isVisited: $0.lastVisitedAt != nil
            )
        }
    }

    private func makeFolderCellDisplays() async throws -> [FolderCellDisplay] {
        let folder = try await fetchFolderUseCase.execute(parentFolderID: nil).get()
        folders = folder.folders

        return folder.folders.map {
            FolderCellDisplay(
                title: $0.title,
                itemCount: $0.clips.count
            )
        }
    }

    private func handleTapDelete(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0 where indexPath.item < unvisitedClips.count:
            let clip = unvisitedClips[indexPath.item]
            Task { await delete(clip, with: deleteClipUseCase.execute) }
        case 1 where indexPath.item < folders.count:
            let folder = folders[indexPath.item]
            Task { await delete(folder, with: deleteFolderUseCase.execute) }
        default:
            break
        }
    }

    private func delete<T>(
        _ target: T,
        with execute: @escaping (T) async -> Result<Void, Error>
    ) async {
        let result = await execute(target)
        switch result {
        case .success:
            await makeHomeDisplay()
        case .failure(let error):
            print(error)
        }
    }
}
