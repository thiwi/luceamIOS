import Foundation

/// Persists the anonymous session token between launches.
@MainActor
class SessionStore: ObservableObject {
    /// The currently active session token.
    @Published var token: String?

    /// User defaults key used for persistence.
    private let key = "sessionToken"

    init() {
        self.token = UserDefaults.standard.string(forKey: key)
    }

    /// Ensures a session token exists, creating one if needed.
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
