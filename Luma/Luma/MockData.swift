import Foundation

class MockData {
    static var events: [Event] = [
        Event(id: 1, content: "A sunny walk in the park", mood: nil, symbol: nil),
        Event(id: 2, content: "Coffee with friends", mood: nil, symbol: nil),
        Event(id: 3, content: "Reading a good book", mood: nil, symbol: nil)
    ]

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
