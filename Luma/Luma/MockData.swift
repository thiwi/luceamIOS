import Foundation

class MockData {
    static var events: [Event] = [
        Event(id: 1, content: "A sunny walk in the park", mood: nil, symbol: nil),
        Event(id: 2, content: "Coffee with friends", mood: nil, symbol: nil),
        Event(id: 3, content: "Reading a good book", mood: nil, symbol: nil)
    ]

    static var moodRooms: [MoodRoom] = [
        MoodRoom(name: "Monday Blues", schedule: "Every Monday at 17:30"),
        MoodRoom(name: "Mindful night routine", schedule: "Daily at 22:00"),
        MoodRoom(name: "Saturday for Reflection", schedule: "Every Saturday at 10:00")
    ]

    static func addMoodRoom(name: String, schedule: String) {
        moodRooms.append(MoodRoom(name: name, schedule: schedule))
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
