import Foundation

protocol FetchClipUseCase {
    func execute(id: UUID) async -> Result<Clip, Error>
}
