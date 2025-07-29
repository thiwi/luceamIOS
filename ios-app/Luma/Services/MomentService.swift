import Foundation

struct Moment: Codable, Identifiable {
    let id: Int
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

    func postMoment(text: String) async throws {
        if APIClient.useMock {
            _ = MockData.addEvent(content: text)
            return
        }
        var request = URLRequest(url: base.appendingPathComponent("moments"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["text": text])
        _ = try await URLSession.shared.data(for: request)
    }

    func postResonance(momentId: UUID) async throws {
        if APIClient.useMock { return }
        var request = URLRequest(url: base.appendingPathComponent("resonance"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["momentId": momentId.uuidString])
        _ = try await URLSession.shared.data(for: request)
    }
}
