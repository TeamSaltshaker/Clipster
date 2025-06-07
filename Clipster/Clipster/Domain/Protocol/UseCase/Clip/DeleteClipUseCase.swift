protocol DeleteClipUseCase {
    func execute(_ clip: Clip) async -> Result<Void, Error>
}
