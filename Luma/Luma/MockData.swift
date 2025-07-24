import Foundation

class MockData {
    static var events: [Event] = [
        Event(id: 1, content: "A sunny walk in the park", mood: nil, symbol: nil),
        Event(id: 2, content: "Coffee with friends", mood: nil, symbol: nil),
        Event(id: 3, content: "Reading a good book", mood: nil, symbol: nil)
    ]

    static var presetMoodRooms: [MoodRoom] = [
        MoodRoom(name: "Monday Blues", schedule: "Every Monday at 17:30", background: "MoodRoomSad"),
        MoodRoom(name: "Mindful night routine", schedule: "Daily at 22:00", background: "MoodRoomNight"),
        MoodRoom(name: "Saturday for Reflection", schedule: "Every Saturday at 10:00", background: "MoodRoomNature")
    ]

    static var userMoodRooms: [MoodRoom] = []

    static var moodRooms: [MoodRoom] {
        userMoodRooms + presetMoodRooms
    }

    static func addMoodRoom(name: String, schedule: String, background: String) {
        userMoodRooms.insert(MoodRoom(name: name, schedule: schedule, background: background), at: 0)
    }

    static func addEvent(content: String) -> Event {
        let newId = (events.map { $0.id }.max() ?? 0) + 1
        let event = Event(id: newId, content: content, mood: nil, symbol: nil)
        events.append(event)
        return event
    }

    static func event(id: Int) -> Event? {
        events.first { $0.id == id }
    }
}
