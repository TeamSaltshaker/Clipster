import Foundation

protocol ClipRepository {
    func fetchClip(by id: UUID) -> Result<Clip, DomainError>
    func fetchUnvisitedClips() -> Result<[Clip], DomainError>
    func createClip(_ clip: Clip) -> Result<Void, DomainError>
    func updateClip(_ clip: Clip) -> Result<Void, DomainError>
    func deleteClip(_ clip: Clip) -> Result<Void, DomainError>
}
