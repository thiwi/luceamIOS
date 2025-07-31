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

    init(id: UUID,
         name: String,
         schedule: String,
         background: String,
         textColor: String,
         startTime: Date,
         createdAt: Date,
         durationMinutes: Int,
         sessionToken: String?) {
        self.id = id
        self.name = name
        self.schedule = schedule
        self.background = background
        self.textColor = textColor
        self.startTime = startTime
        self.createdAt = createdAt
        self.durationMinutes = durationMinutes
        self.sessionToken = sessionToken
    }

    enum CodingKeys: String, CodingKey {
        case id, name, schedule, background, textColor, startTime, createdAt, durationMinutes, sessionToken, session
    }

    enum SessionKeys: String, CodingKey {
        case token
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        schedule = try container.decode(String.self, forKey: .schedule)
        background = try container.decode(String.self, forKey: .background)
        textColor = try container.decode(String.self, forKey: .textColor)
        startTime = try container.decode(Date.self, forKey: .startTime)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        if let token = try container.decodeIfPresent(String.self, forKey: .sessionToken) {
            sessionToken = token
        } else if container.contains(.session) {
            let nested = try container.nestedContainer(keyedBy: SessionKeys.self, forKey: .session)
            sessionToken = try nested.decodeIfPresent(String.self, forKey: .token)
        } else {
            sessionToken = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(background, forKey: .background)
        try container.encode(textColor, forKey: .textColor)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(durationMinutes, forKey: .durationMinutes)
        try container.encodeIfPresent(sessionToken, forKey: .sessionToken)
    }
}

class MoodRoomService {
    private let base = URL(string: BASE_API_URL)!
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    func fetchRooms() async throws -> [MoodRoom] {
        let url = base.appendingPathComponent("moodrooms")
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try decoder.decode([NetworkMoodRoom].self, from: data)
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
        request.httpBody = try encoder.encode(enc)
        let (data, _) = try await URLSession.shared.data(for: request)
        let saved = try decoder.decode(NetworkMoodRoom.self, from: data)
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
