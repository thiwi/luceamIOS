import SwiftUI

struct MoodRoomListView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                Image("MainViewBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(MockData.userMoodRooms) { room in
                            if room.isActive {
                                NavigationLink(destination: MoodRoomView(name: room.name, background: room.background)) {
                                    MoodRoomCardView(room: room)
                                }
                            } else {
                                MoodRoomCardView(room: room)
                                    .opacity(0.6)
                            }
                        }
                        if !MockData.userMoodRooms.isEmpty {
                            Divider()
                        }
                        ForEach(MockData.presetMoodRooms) { room in
                            if room.isActive {
                                NavigationLink(destination: MoodRoomView(name: room.name, background: room.background)) {
                                    MoodRoomCardView(room: room)
                                }
                            } else {
                                MoodRoomCardView(room: room)
                                    .opacity(0.6)
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
    }
}

#Preview {
    MoodRoomListView()
}
