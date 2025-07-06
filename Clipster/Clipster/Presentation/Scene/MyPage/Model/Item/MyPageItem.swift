import UIKit

enum MyPageItem: Hashable {
    case login(LoginType)
    case sectionTitle(String)
    case detail(DetailItem)
    case dropdown(DropdownItem)
    case chevron(ChevronItem)
    case account(AccountItem)
    case version(String)
}

extension MyPageItem {
    var titleText: String? {
        switch self {
        case .sectionTitle(let text): text
        case .detail(let item): item.title
        case .dropdown(let item): item.title
        case .chevron(let item): item.title
        case .account(let item): item.title
        case .version: "버전 정보"
        default: nil
        }
    }

    var titleFont: UIFont {
        switch self {
        case .sectionTitle: .pretendard(size: 12, weight: .semiBold)
        case .account: .pretendard(size: 14, weight: .medium)
        case .version: .pretendard(size: 12, weight: .regular)
        default: .pretendard(size: 16, weight: .semiBold)
        }
    }

    var titleColor: UIColor {
        switch self {
        case .sectionTitle: .blue600
        case .account(let item): item.titleColor
        case .version: .textSecondary
        default: .textPrimary
        }
    }

    var valueText: String? {
        switch self {
        case .detail(let item): item.value
        case .dropdown(let item): item.value
        case .version(let version): version
        default: nil
        }
    }

    var valueFont: UIFont {
        switch self {
        default: .pretendard(size: 12, weight: .regular)
        }
    }

    var valueColor: UIColor {
        switch self {
        default: .textSecondary
        }
    }

    var rightIcon: UIImage? {
        switch self {
        case .dropdown(let item): item.image.withTintColor(.textSecondary)
        case .chevron: .chevronRight.withTintColor(.textPrimary)
        default: nil
        }
    }
}
