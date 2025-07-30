import Foundation

struct Moment: Codable, Identifiable {
    /// Unique identifier represented as a GUID string.
    let id: String
    let content: String
}

class MomentService {
    private let base = URL(string: BASE_API_URL)!

    func fetchMoments() async throws -> [Moment] {
        if APIClient.useMock {
            return MockData.events.map { Moment(id: $0.id, content: $0.content) }
        }
        let url = base.appendingPathComponent("moments")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Moment].self, from: data)
    }

    func postMoment(token: String, text: String) async throws -> Moment {
        if APIClient.useMock {
            return MockData.addEvent(content: text).toMoment()
        }
        var components = URLComponents(url: base.appendingPathComponent("moments"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "session_token", value: token)]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["content": text])
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Moment.self, from: data)
    }

    func postResonance(momentId: String) async throws {
        if APIClient.useMock { return }
        var request = URLRequest(url: base.appendingPathComponent("resonance"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["momentId": momentId])
        _ = try await URLSession.shared.data(for: request)
    }
}
