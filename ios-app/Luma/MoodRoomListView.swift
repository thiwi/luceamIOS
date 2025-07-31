import SwiftUI

/// List of both user created and preset mood rooms.
struct MoodRoomListView: View {
    /// Allows the view to dismiss itself when done.
    @Environment(\.dismiss) private var dismiss

    /// Access to the current session token.
    @EnvironmentObject private var session: SessionStore

    /// Favourite mood rooms store.
    @EnvironmentObject private var favourites: FavoritesStore

    /// Loads rooms from the backend.
    @StateObject private var store = MoodRoomStore()

    /// Timer updated so the joinability of rooms updates live.
    @State private var now = Date()

    /// Currently edited room.
    @State private var editingRoom: MoodRoom?

    /// View body listing all mood rooms.
    var body: some View {
        let _ = now
        NavigationStack {
            ZStack {
                Image("MainViewBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        let ownRooms = store.rooms.filter { $0.sessionToken == session.token }
                        let otherRooms = store.rooms.filter { $0.sessionToken != session.token }
                        if !ownRooms.isEmpty {
                            Text("Your mood rooms")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        ForEach(ownRooms) { room in
                            ZStack(alignment: .topLeading) {
                                if room.isJoinable {
                                    NavigationLink(destination: MoodRoomView(room: room,
                                                                           isPreview: false,
                                                                           isOwnRoom: true)) {
                                        MoodRoomCardView(room: room)
                                            .id(room)
                                    }
                                } else {
                                    MoodRoomCardView(room: room)
                                        .id(room)
                                }
                                Button(action: { editingRoom = room }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.black)
                                        .padding(6)
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(Circle())
                                }
                                .padding(8)
                            }
                        }

                        if !ownRooms.isEmpty {
                            Divider()
                            Text("Mood rooms created by others")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        ForEach(otherRooms) { room in
                            if room.isJoinable {
                                NavigationLink(destination: MoodRoomView(room: room)) {
                                    MoodRoomCardView(room: room)
                                        .id(room)
                                }
                            } else {
                                MoodRoomCardView(room: room)
                                    .id(room)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical)
                }
            }
            .navigationTitle("Mood Rooms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.black)
                }
            }
        }
        // Update the `now` state every minute so joinability recalculates.
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            now = Date()
        }
        .sheet(item: $editingRoom) { room in
            CreateMoodRoomView(editingRoom: room) { _, _ in } onUpdate: { _ in
                editingRoom = nil
                now = Date()
            } onDelete: { _ in
                editingRoom = nil
                now = Date()
            }
        }
        .task {
            await store.load(token: session.token)
        }
    }
}

#Preview {
    // Preview showing all mood rooms.
    MoodRoomListView()
        .environmentObject(SessionStore())
        .environmentObject(FavoritesStore())
}
