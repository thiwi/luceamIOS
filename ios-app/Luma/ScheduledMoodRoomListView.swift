import SwiftUI

struct ScheduledMoodRoomListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var favourites: FavoritesStore
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        NavigationStack {
            ZStack {
                Image("MainViewBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 16) {
                        let rooms = favourites.rooms.sorted { $0.startTime < $1.startTime }
                        ForEach(rooms) { room in
                            if room.isJoinable {
                                NavigationLink(destination: MoodRoomView(room: room)) {
                                    MoodRoomCardView(room: room)
                                }
                            } else {
                                MoodRoomCardView(room: room)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical)
                }
            }
            .navigationTitle("Scheduled MoodRooms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.black)
                }
            }
        }
        .task {
            await favourites.loadFavorites()
        }
    }
}

#Preview {
    ScheduledMoodRoomListView()
        .environmentObject(FavoritesStore())
        .environmentObject(SessionStore())
}
