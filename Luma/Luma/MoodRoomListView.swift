import SwiftUI

struct MoodRoomListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var now = Date()
    @State private var editingRoom: MoodRoom?
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
                        if !MockData.userMoodRooms.isEmpty {
                            Text("Your mood rooms")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        ForEach(MockData.userMoodRooms) { room in
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

                        if !MockData.userMoodRooms.isEmpty {
                            Divider()
                            Text("Mood rooms created by others")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        ForEach(MockData.presetMoodRooms) { room in
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
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            now = Date()
        }
        .sheet(item: $editingRoom) { room in
            CreateMoodRoomView(editingRoom: room) { _, _ in } onUpdate: { _ in
                editingRoom = nil
                now = Date()
            }
        }
    }
}

#Preview {
    MoodRoomListView()
}
