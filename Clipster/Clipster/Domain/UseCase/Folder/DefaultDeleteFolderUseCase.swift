final class DefaultDeleteFolderUseCase: DeleteFolderUseCase {
    func execute(_ folder: Folder) async -> Result<Void, Error> {
        .success(())
    }
}
