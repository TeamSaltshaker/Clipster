import Foundation

protocol AuthService {
    func currentUserID() -> UUID?
    func login(loginType: LoginType, token: String) async -> Result<UUID, Error>
    func logout() async -> Result<Void, Error>
    func withdraw() async -> Result<Void, Error>
}
