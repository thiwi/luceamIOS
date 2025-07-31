import Foundation
import SwiftUI

@MainActor
class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteIds: Set<UUID>
    private let key = "favoriteMoodRooms"

    init() {
        if let stored = UserDefaults.standard.array(forKey: key) as? [String] {
            favoriteIds = Set(stored.compactMap { UUID(uuidString: $0) })
        } else {
            favoriteIds = []
        }
    }

    func isFavorite(_ room: MoodRoom) -> Bool {
        favoriteIds.contains(room.id)
    }

    func toggle(_ room: MoodRoom) {
        if favoriteIds.contains(room.id) {
            favoriteIds.remove(room.id)
        } else {
            favoriteIds.insert(room.id)
        }
        save()
    }

    private func save() {
        let arr = favoriteIds.map { $0.uuidString }
        UserDefaults.standard.set(arr, forKey: key)
    }
}
