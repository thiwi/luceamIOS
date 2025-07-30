import Foundation

/// Basic REST client used by the app's stores.
class APIClient {
    /// Singleton instance used throughout the app.
    static let shared = APIClient()

    /// Toggle this flag to use mock data instead of hitting the network.
    /// When `true` API calls return local ``MockData`` instead of hitting the backend.
    static var useMock = false

    /// Base URL for the backend server.
    private let baseURL = URL(string: BASE_API_URL)!

    private init() {}

    /// Creates an anonymous user session on the backend.
    func createSession() async throws -> Session {
        if APIClient.useMock {
            return Session(token: "mock-token")
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("session"))
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Session.self, from: data)
    }

    /// Retrieves the list of available moments from the API.
    func listEvents() async throws -> [Event] {
        if APIClient.useMock {
            return MockData.events
        }

        let url = baseURL.appendingPathComponent("moments")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Event].self, from: data)
    }

    /// Posts a new event using the provided session token.
    func createEvent(token: String, event: EventCreate) async throws -> Event {
        if APIClient.useMock {
            return MockData.addEvent(content: event.content)
        }

        var components = URLComponents(url: baseURL.appendingPathComponent("moments"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "session_token", value: token)]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(event)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Event.self, from: data)
    }

    /// Fetches the full details for a single event by id.
    func fetchEvent(id: String) async throws -> Event {
        if APIClient.useMock {
            return MockData.event(id: id) ?? MockData.events.first!
        }

        let url = baseURL.appendingPathComponent("moments/\(id)")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Event.self, from: data)
    }
}
