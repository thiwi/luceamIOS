import Foundation
import SwiftUI

@MainActor
class MoodRoomStore: ObservableObject {
    private let service = MoodRoomService()
    @Published var rooms: [MoodRoom] = []

    func load(token: String?) async {
        do {
            rooms = try await service.fetchRooms()
        } catch {
            print("Failed to load mood rooms", error)
            rooms = []
        }
    }

    func create(token: String, room: MoodRoom) async {
        do {
            _ = try await service.postRoom(token: token, room: room)
            await load(token: token)
        } catch {
            print("Failed to create mood room", error)
        }
    }
}
