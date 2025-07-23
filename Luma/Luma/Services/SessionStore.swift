import Foundation

@MainActor
class SessionStore: ObservableObject {
    @Published var token: String?
    private let key = "sessionToken"

    init() {
        self.token = UserDefaults.standard.string(forKey: key)
    }

    func ensureSession() async {
        if token != nil { return }
        do {
            let sess = try await APIClient.shared.createSession()
            token = sess.token
            UserDefaults.standard.set(sess.token, forKey: key)
        } catch {
            print("Session creation failed", error)
            // Use a mock token so the app can run without the backend
            token = "mock-token"
        }
    }
}
