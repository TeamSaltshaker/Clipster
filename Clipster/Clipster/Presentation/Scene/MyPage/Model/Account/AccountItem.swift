import UIKit

enum AccountItem: Hashable {
    case logout
    case withdraw
}

extension AccountItem {
    var title: String {
        switch self {
        case .logout: "로그아웃"
        case .withdraw: "회원탈퇴"
        }
    }

    var titleColor: UIColor {
        switch self {
        case .logout: .textPrimary
        case .withdraw: .red600
        }
    }
}
