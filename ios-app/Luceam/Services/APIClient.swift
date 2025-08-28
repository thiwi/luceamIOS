import Foundation

/// Basic REST client used by the app's stores.
class APIClient {
    /// Singleton instance used throughout the app.
    static let shared = APIClient()


    /// Base URL for the backend server.
    private let baseURL = URL(string: BASE_API_URL)!

    private init() {}

    /// Creates an anonymous user session on the backend.
    func createSession() async throws -> Session {
        var request = URLRequest(url: baseURL.appendingPathComponent("session"))
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Session.self, from: data)
    }

    /// Retrieves the list of available moments from the API.
    func listEvents() async throws -> [Event] {
        let url = baseURL.appendingPathComponent("moments")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Event].self, from: data)
    }

    /// Posts a new event using the provided session token.
    func createEvent(token: String, event: EventCreate) async throws -> Event {
        let url = baseURL.appendingPathComponent("moments")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["content": event.content, "mood": event.mood, "symbol": event.symbol, "session_token": token]
        request.httpBody = try JSONEncoder().encode(payload)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Event.self, from: data)
    }

    /// Fetches the full details for a single event by id.
    func fetchEvent(id: String) async throws -> Event {
        let url = baseURL.appendingPathComponent("moments/\(id)")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Event.self, from: data)
    }
}
