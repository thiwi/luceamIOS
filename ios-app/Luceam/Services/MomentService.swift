import Foundation

struct Moment: Codable, Identifiable {
    /// Unique identifier represented as a GUID string.
    let id: String
    let content: String
}

class MomentService {
    private let base = URL(string: BASE_API_URL)!

    func fetchMoments() async throws -> [Moment] {
        let url = base.appendingPathComponent("moments")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Moment].self, from: data)
    }

    func postMoment(token: String, text: String) async throws -> Moment {
        let url = base.appendingPathComponent("moments")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["content": text, "session_token": token])
        let (data, _) = try await URLSession.shared.data(for: request)
        print("📥 Raw response:", String(data: data, encoding: .utf8) ?? "nil")
        return try JSONDecoder().decode(Moment.self, from: data)
    }

    func postResonance(momentId: String) async throws {
        var request = URLRequest(url: base.appendingPathComponent("resonance"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["momentId": momentId])
        _ = try await URLSession.shared.data(for: request)
    }
}
