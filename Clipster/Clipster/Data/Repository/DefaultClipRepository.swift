import Foundation

final class DefaultClipRepository: ClipRepository {
    private let storage: ClipStorage
    private let mapper: DomainMapper

    init(
        storage: ClipStorage,
        mapper: DomainMapper,
    ) {
        self.storage = storage
        self.mapper = mapper
    }

    func fetchClip(by id: UUID) -> Result<Clip, DomainError> {
        storage.fetchClip(by: id)
            .mapError { _ in .unknownError }
            .flatMap { entity in
                guard let clip = mapper.clip(from: entity) else {
                    return .failure(.unknownError)
                }
                return .success(clip)
            }
    }

    func fetchUnvisitedClips() -> Result<[Clip], DomainError> {
        storage.fetchUnvisitedClips()
            .mapError { _ in .unknownError }
            .flatMap { entities in
                let clips = entities.compactMap(mapper.clip)
                return .success(clips)
            }
    }

    func createClip(_ clip: Clip) -> Result<Void, DomainError> {
        storage.insertClip(clip)
            .mapError { _ in .unknownError }
    }

    func updateClip(_ clip: Clip) -> Result<Void, DomainError> {
        storage.updateClip(clip)
            .mapError { _ in .unknownError }
    }

    func deleteClip(_ clip: Clip) -> Result<Void, DomainError> {
        storage.deleteClip(clip)
            .mapError { _ in .unknownError }
    }
}
