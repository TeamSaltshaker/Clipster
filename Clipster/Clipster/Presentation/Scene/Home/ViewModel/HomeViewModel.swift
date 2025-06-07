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
        case showWebView
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

    init(
        fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase,
        fetchFolderUseCase: FetchFolderUseCase,
        deleteClipUseCase: DeleteClipUseCase
    ) {
        self.fetchUnvisitedClipsUseCase = fetchUnvisitedClipsUseCase
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteClipUseCase = deleteClipUseCase
        bind()
    }

    private func bind() {
        action
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewWillAppear:
                    Task { await owner.makeHomeDisplay() }
                case .tapAddClip:
                    print("클립 추가")
                case .tapAddFolder:
                    print("폴더 추가")
                case .tapCell(let indexPath):
                    print("tapCell \(indexPath)")
                case .tapDetail(let indexPath):
                    print("tapDetail \(indexPath)")
                case .tapEdit(let indexPath):
                    print("tapEdit \(indexPath)")
                case .tapDelete(let indexPath):
                    print("tapDelete \(indexPath)")
                case .tapLicense:
                    print("라이센스")
                }
            }
            .disposed(by: disposeBag)
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

    private func deleteClip(_ clip: Clip) async {
        let result = await deleteClipUseCase.execute(clip)
        switch result {
        case .success:
            await makeHomeDisplay()
        case .failure(let error):
            print(error)
        }
    }
}
