import Foundation
import SwiftUI

/// In-memory structures used when ``APIClient.useMock`` is `true`.
class MockData {
    static var events: [Event] = [
        Event(id: UUID().uuidString, content: "A sunny walk in the park", mood: nil, symbol: nil),
        Event(id: UUID().uuidString, content: "Coffee with friends", mood: nil, symbol: nil),
        Event(id: UUID().uuidString, content: "Reading a good book", mood: nil, symbol: nil)
    ]

    static var presetMoodRooms: [MoodRoom] = [
        MoodRoom(name: "Monday Blues",
                 schedule: "Every Monday at 17:30",
                 background: "MoodRoomSad",
                 textColor: .black,
                 startTime: Date().addingTimeInterval(600),
                 createdAt: Date(),
                 durationMinutes: 30),
        MoodRoom(name: "Mindful night routine",
                 schedule: "Daily at 22:00",
                 background: "MoodRoomNight",
                 textColor: .white,
                 startTime: Date().addingTimeInterval(900),
                 createdAt: Date(),
                 durationMinutes: 30),
        MoodRoom(name: "Saturday for Reflection",
                 schedule: "Every Saturday at 10:00",
                 background: "MoodRoomNature",
                 textColor: .black,
                 startTime: Date().addingTimeInterval(1200),
                 createdAt: Date(),
                 durationMinutes: 30)
    ]

    static var userMoodRooms: [MoodRoom] = []

    static var moodRooms: [MoodRoom] {
        userMoodRooms + presetMoodRooms
    }

    /// Inserts a new mood room at the top of the user's list.
    static func addMoodRoom(name: String,
                             schedule: String,
                             background: String,
                             textColor: Color = .black,
                             startTime: Date,
                             durationMinutes: Int) {
        userMoodRooms.insert(MoodRoom(name: name,
                                      schedule: schedule,
                                      background: background,
                                     textColor: textColor,
                                      startTime: startTime,
                                      createdAt: Date(),
                                      durationMinutes: durationMinutes),
                             at: 0)
    }

    /// Replaces an existing mood room with updated details.
    static func updateMoodRoom(id: UUID,
                               name: String,
                               schedule: String,
                               background: String,
                               textColor: Color = .black,
                               startTime: Date,
                               durationMinutes: Int) {
        if let index = userMoodRooms.firstIndex(where: { $0.id == id }) {
            userMoodRooms[index] = MoodRoom(id: id,
                                           name: name,
                                           schedule: schedule,
                                           background: background,
                                           textColor: textColor,
                                           startTime: startTime,
                                           createdAt: userMoodRooms[index].createdAt,
                                           durationMinutes: durationMinutes)
        }
    }

    /// Removes a mood room from the user's list.
    static func deleteMoodRoom(id: UUID) {
        if let index = userMoodRooms.firstIndex(where: { $0.id == id }) {
            userMoodRooms.remove(at: index)
        }
    }

    /// Adds and returns a new event with a unique identifier.
    static func addEvent(content: String) -> Event {
        let event = Event(id: UUID().uuidString, content: content, mood: nil, symbol: nil)
        events.append(event)
        return event
    }

    /// Returns an event matching the given identifier if present.
    static func event(id: String) -> Event? {
        events.first { $0.id == id }
    }
}
