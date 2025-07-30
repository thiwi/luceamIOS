import Foundation
import SwiftUI

struct NetworkMoodRoom: Codable {
    var id: UUID
    var name: String
    var schedule: String
    var background: String
    var textColor: String
    var startTime: Date
    var createdAt: Date
    var durationMinutes: Int
    var sessionToken: String?
}

class MoodRoomService {
    private let base = URL(string: BASE_API_URL)!

    func fetchRooms() async throws -> [MoodRoom] {
        if APIClient.useMock {
            return MockData.moodRooms
        }
        let url = base.appendingPathComponent("moodrooms")
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode([NetworkMoodRoom].self, from: data)
        return decoded.map { MoodRoom(id: $0.id,
                                      name: $0.name,
                                      schedule: $0.schedule,
                                      background: $0.background,
                                      textColor: $0.textColor.lowercased() == "white" ? .white : .black,
                                      startTime: $0.startTime,
                                      createdAt: $0.createdAt,
                                      durationMinutes: $0.durationMinutes,
                                      sessionToken: $0.sessionToken) }
    }

    func postRoom(token: String, room: MoodRoom) async throws -> MoodRoom {
        if APIClient.useMock {
            MockData.addMoodRoom(name: room.name,
                                 schedule: room.schedule,
                                 background: room.background,
                                 textColor: room.textColor,
                                 startTime: room.startTime,
                                 durationMinutes: room.durationMinutes)
            return MockData.userMoodRooms.first!
        }
        var comps = URLComponents(url: base.appendingPathComponent("moodrooms"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "session_token", value: token)]
        var request = URLRequest(url: comps.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let enc = NetworkMoodRoom(id: room.id,
                                  name: room.name,
                                  schedule: room.schedule,
                                  background: room.background,
                                  textColor: room.textColor == .white ? "white" : "black",
                                  startTime: room.startTime,
                                  createdAt: room.createdAt,
                                  durationMinutes: room.durationMinutes,
                                  sessionToken: nil)
        request.httpBody = try JSONEncoder().encode(enc)
        let (data, _) = try await URLSession.shared.data(for: request)
        let saved = try JSONDecoder().decode(NetworkMoodRoom.self, from: data)
        return MoodRoom(id: saved.id,
                        name: saved.name,
                        schedule: saved.schedule,
                        background: saved.background,
                        textColor: saved.textColor.lowercased() == "white" ? .white : .black,
                        startTime: saved.startTime,
                        createdAt: saved.createdAt,
                        durationMinutes: saved.durationMinutes,
                        sessionToken: saved.sessionToken)
    }
}
