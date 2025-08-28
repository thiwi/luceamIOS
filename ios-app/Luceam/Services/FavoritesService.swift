import Foundation
import SwiftUI

struct NetworkFavoriteResponse: Codable {
    let isFavorite: Bool
}

class FavoritesService {
    private let base = URL(string: BASE_API_URL)!
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            if let date = fmt.date(from: str) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date")
        }
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    func fetchFavorites(userId: String) async throws -> [MoodRoom] {
        let url = base.appendingPathComponent("favorites/\(userId)")
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try decoder.decode([NetworkMoodRoom].self, from: data)
        return decoded.map { $0.toMoodRoom() }
    }

    func toggleFavorite(userId: String, moodRoomId: UUID) async throws -> Bool {
        var request = URLRequest(url: base.appendingPathComponent("favorites"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(["userId": userId, "moodRoomId": moodRoomId.uuidString])
        let (data, _) = try await URLSession.shared.data(for: request)
        let resp = try decoder.decode(NetworkFavoriteResponse.self, from: data)
        return resp.isFavorite
    }
}
