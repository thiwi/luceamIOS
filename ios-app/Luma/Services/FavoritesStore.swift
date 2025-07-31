import Foundation
import SwiftUI

@MainActor
class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteIds: Set<UUID> = []
    @Published var rooms: [MoodRoom] = []

    private let service = FavoritesService()
    private let userId = HARDCODED_USER_ID

    func loadFavorites() async {
        do {
            rooms = try await service.fetchFavorites(userId: userId)
            favoriteIds = Set(rooms.map { $0.id })
        } catch {
            print("Failed to load favorites", error)
            rooms = []
            favoriteIds = []
        }
    }

    func isFavorite(_ room: MoodRoom) -> Bool {
        favoriteIds.contains(room.id)
    }

    func toggle(_ room: MoodRoom) async {
        do {
            let newState = try await service.toggleFavorite(userId: userId, moodRoomId: room.id)
            if newState {
                favoriteIds.insert(room.id)
                if !rooms.contains(where: { $0.id == room.id }) {
                    rooms.append(room)
                }
            } else {
                favoriteIds.remove(room.id)
                rooms.removeAll { $0.id == room.id }
            }
        } catch {
            print("Failed to toggle favorite", error)
        }
    }
}
