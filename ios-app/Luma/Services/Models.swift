import Foundation

struct Session: Codable {
    let token: String
}

struct Event: Codable, Identifiable {
    let id: Int
    let content: String
    let mood: String?
    let symbol: String?
}

struct EventCreate: Codable {
    let content: String
    let mood: String
    let symbol: String
}
