import Foundation

final class DefaultFolderRepository: FolderRepository {
    private let storage: FolderStorage
    private let cache: FolderClipCache?

    init(storage: FolderStorage, cache: FolderClipCache?) {
        self.storage = storage
        self.cache = cache
    }

    func fetchFolder(by id: UUID) async -> Result<Folder, DomainError> {
        if let cache,
           await cache.isFoldersInitialized {
            guard let folder = await cache.folder(by: id) else {
                return .failure(.entityNotFound)
            }
            return .success(folder)
        } else {
            return await storage.fetchFolder(by: id)
                .mapError { _ in .fetchFailed }
        }
    }

    func fetchAllFolders() async -> Result<[Folder], DomainError> {
        if let cache,
           await cache.isFoldersInitialized {
            let folders = await cache.folders()
            return .success(folders.filter { $0.deletedAt == nil })
        } else {
            return await storage.fetchAllFolders()
                .mapError { _ in .fetchFailed }
        }
    }

    func fetchTopLevelFolders() async -> Result<[Folder], DomainError> {
        if let cache,
           await cache.isFoldersInitialized {
            let folders = await cache.folders()
            return .success(folders.filter { $0.parentFolderID == nil && $0.deletedAt == nil })
        } else {
            return await storage.fetchTopLevelFolders()
                .mapError { _ in .fetchFailed }
        }
    }

    func insertFolder(_ folder: Folder) async -> Result<Void, DomainError> {
        let result = await storage.insertFolder(folder)

        switch result {
        case .success:
            if let cache,
               await cache.isFoldersInitialized {
                await cache.setFolder(folder)
            }
            return .success(())
        case .failure:
            return .failure(.insertFailed)
        }
    }

    func updateFolder(_ folder: Folder) async -> Result<Void, DomainError> {
        let result = await storage.updateFolder(folder)

        switch result {
        case .success:
            if let cache,
               await cache.isFoldersInitialized {
                await cache.setFolder(folder)
            }
            return .success(())
        case .failure:
            return .failure(.updateFailed)
        }
    }

    func deleteFolder(_ folder: Folder) async -> Result<Void, DomainError> {
        let result = await storage.deleteFolder(folder)

        switch result {
        case .success:
            if let cache,
               await cache.isFoldersInitialized {
                await cache.setFolder(folder)
            }
            return .success(())
        case .failure:
            return .failure(.deleteFailed)
        }
    }
}
