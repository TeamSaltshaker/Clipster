import Foundation

final class DefaultSaveThemeOptionUseCase: SaveThemeOptionUseCase {
    private let userDefaults: UserDefaults
    private let key = "appThemeOption"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func execute(_ option: ThemeOption) async -> Result<Void, Error> {
        userDefaults.set(option.rawValue, forKey: key)
        await AppThemeManager.shared.apply(theme: option)
        return .success(())
    }
}
