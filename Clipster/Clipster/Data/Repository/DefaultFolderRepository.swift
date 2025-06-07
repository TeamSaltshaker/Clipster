import Foundation

final class DefaultFolderRepository: FolderRepository {
    private let storage: FolderStorage
    private let mapper: DomainMapper

    init(
        storage: FolderStorage,
        mapper: DomainMapper,
    ) {
        self.storage = storage
        self.mapper = mapper
    }

    func fetchFolder(by id: UUID) -> Result<Folder, DomainError> {
        storage.fetchFolder(by: id)
            .mapError { _ in .unknownError }
            .flatMap { entity in
                guard let folder = mapper.folder(from: entity) else {
                    return .failure(.unknownError)
                }
                return .success(folder)
            }
    }

    func fetchTopLevelFolders() -> Result<[Folder], DomainError> {
        storage.fetchTopLevelFolders()
            .mapError { _ in .unknownError }
            .flatMap { entities in
                let folders = entities.compactMap(mapper.folder)
                return .success(folders)
            }
    }

    func insertFolder(_ folder: Folder) -> Result<Void, DomainError> {
        storage.insertFolder(folder)
            .mapError { _ in .unknownError }
    }

    func updateFolder(_ folder: Folder) -> Result<Void, DomainError> {
        storage.updateFolder(folder)
            .mapError { _ in .unknownError }
    }

    func deleteFolder(_ folder: Folder) -> Result<Void, DomainError> {
        storage.deleteFolder(folder)
            .mapError { _ in .unknownError }
    }
}
