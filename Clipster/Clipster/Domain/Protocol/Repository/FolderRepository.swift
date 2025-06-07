import Foundation

protocol FolderRepository {
    func fetchFolder(by id: UUID) -> Result<Folder, DomainError>
    func fetchTopLevelFolders() -> Result<[Folder], DomainError>
    func insertFolder(_ folder: Folder) -> Result<Void, DomainError>
    func updateFolder(_ folder: Folder) -> Result<Void, DomainError>
    func deleteFolder(_ folder: Folder) -> Result<Void, DomainError>
}
