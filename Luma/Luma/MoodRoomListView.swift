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
                            NavigationLink(destination: MoodRoomView(name: room.name, background: room.background)) {
                                MoodRoomCardView(room: room)
                            }
                        }
                        if !MockData.userMoodRooms.isEmpty {
                            Divider()
                        }
                        ForEach(MockData.presetMoodRooms) { room in
                            NavigationLink(destination: MoodRoomView(name: room.name, background: room.background)) {
                                MoodRoomCardView(room: room)
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
