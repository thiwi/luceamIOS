import Foundation

class APIClient {
    static let shared = APIClient()
    private let baseURL = URL(string: "http://localhost:8000/api")!

    private init() {}

    func createSession() async throws -> Session {
        var request = URLRequest(url: baseURL.appendingPathComponent("session"))
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Session.self, from: data)
    }

    func listEvents() async throws -> [Event] {
        let url = baseURL.appendingPathComponent("events")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Event].self, from: data)
    }

    func createEvent(token: String, event: EventCreate) async throws -> Event {
        var components = URLComponents(url: baseURL.appendingPathComponent("events"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "session_token", value: token)]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(event)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Event.self, from: data)
    }

    func fetchEvent(id: Int) async throws -> Event {
        let url = baseURL.appendingPathComponent("events/\(id)")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Event.self, from: data)
    }
}
