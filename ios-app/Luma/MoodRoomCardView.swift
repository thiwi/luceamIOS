import SwiftUI

/// Compact card displaying a ``MoodRoom`` in lists.
struct MoodRoomCardView: View {
    /// Room to visualise.
    let room: MoodRoom

    /// Provides access to favourite state.
    @EnvironmentObject private var favourites: FavoritesStore

    /// View body showing the background image and text.
    var body: some View {
        let cardWidth = UIScreen.main.bounds.width * 0.95
        let cardHeight = UIScreen.main.bounds.height * 0.2
        ZStack {
            Image(room.background)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: cardWidth, height: cardHeight)
                .clipped()
                .cornerRadius(16)
            VStack {
                let textColor = room.textColor
                Text(room.name)
                    .font(.title2)
                    .foregroundColor(textColor)
                Text(room.schedule + " | \(room.durationMinutes)min")
                    .font(.caption)
                    .foregroundColor(textColor)
            }
            .multilineTextAlignment(.center)
            .padding()
        }
        .frame(width: cardWidth, height: cardHeight)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
        .overlay(alignment: .topTrailing) {
            VStack(alignment: .trailing, spacing: 2) {
                Button(action: {
                    Task { await favourites.toggle(room) }
                }) {
                    Image(systemName: favourites.isFavorite(room) ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(favourites.isFavorite(room) ? (room.background == "MoodRoomNight" ? .white : .black) : .black)
                        .padding(6)
                }
                if !room.isJoinable {
                    Text("Unavailable at the moment")
                        .font(.caption2)
                        .foregroundColor(room.textColor)
                        .padding(6)
                }
            }
        }
        .allowsHitTesting(room.isJoinable)
    }
}

#Preview {
    // Preview with static data for design time.
    MoodRoomCardView(room: MoodRoom(name: "Test",
                                   schedule: "Daily",
                                   background: "MoodRoomHappy",
                                   textColor: .black,
                                   startTime: Date(),
                                   createdAt: Date(),
                                   durationMinutes: 30))
        .environmentObject(FavoritesStore())
}
