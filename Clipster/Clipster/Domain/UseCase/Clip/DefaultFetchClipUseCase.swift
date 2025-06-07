import Foundation

final class DefaultFetchClipUseCase: FetchClipUseCase {
    func execute(id: UUID) async -> Result<Clip, Error> {
        .failure(DummyError.notImplemented)
    }
}
