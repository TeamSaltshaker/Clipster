import UIKit

extension ThemeOption {
    var displayText: String {
        switch self {
        case .system: "시스템 기본"
        case .light: "라이트"
        case .dark: "다크"
        }
    }
}

extension ThemeOption: SelectableOption { }

extension ThemeOption {
    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
}
