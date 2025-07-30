import Foundation

struct Session: Codable {
    let token: String
}

struct Event: Codable, Identifiable {
    /// Unique identifier represented as a GUID string.
    let id: String
    let content: String
    let mood: String?
    let symbol: String?
}

extension Event {
    /// Convenience helper to convert an ``Event`` into ``Moment``.
    func toMoment() -> Moment {
        Moment(id: id, content: content)
    }
}

struct EventCreate: Codable {
    let content: String
    let mood: String
    let symbol: String
}
