import UIKit

@MainActor
final class AppThemeManager {
    static let shared = AppThemeManager()

    func apply(theme: ThemeOption) {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        window?.overrideUserInterfaceStyle = theme.interfaceStyle
    }
}
