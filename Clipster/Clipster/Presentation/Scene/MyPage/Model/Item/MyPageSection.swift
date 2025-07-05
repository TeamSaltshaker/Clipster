enum MyPageSection: Hashable {
    case login
    case welcome(String)
    case profile
    case systemSettings
    case notificationSettings
    case trash
    case support
    case etc
}

extension MyPageSection {
    var title: String {
        switch self {
        case .login: "로그인"
        case .welcome(let nickname): "\(nickname) 님 환영합니다"
        case .profile: "개인정보수정"
        case .systemSettings: "시스템 설정"
        case .notificationSettings: ""
        case .trash: ""
        case .support: ""
        case .etc: ""
        }
    }
}
