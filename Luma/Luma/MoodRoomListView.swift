import SwiftUI

struct MoodRoomListView: View {
    @Environment(\.dismiss) private var dismiss
    let rooms: [MoodRoom] = MockData.moodRooms

    var body: some View {
        NavigationStack {
            ZStack {
                Image("startscreen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(rooms) { room in
                            MoodRoomCardView(room: room)
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
