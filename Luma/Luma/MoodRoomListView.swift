import SwiftUI

struct MoodRoomListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var now = Date()
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
                            if room.isJoinable {
                                NavigationLink(destination: MoodRoomView(room: room,
                                                                       isPreview: false,
                                                                       isOwnRoom: true)) {
                                    MoodRoomCardView(room: room)
                                }
                            } else {
                                MoodRoomCardView(room: room, joinable: false)
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
                                }
                            } else {
                                MoodRoomCardView(room: room, joinable: false)
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
    }
}

#Preview {
    MoodRoomListView()
}
