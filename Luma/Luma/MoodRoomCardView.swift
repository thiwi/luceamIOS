import SwiftUI

struct MoodRoomCardView: View {
    let room: MoodRoom

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
                Text(room.name)
                    .font(.title2)
                    .foregroundColor(.black)
                Text(room.schedule)
                    .font(.caption)
                    .foregroundColor(.black)
            }
            .multilineTextAlignment(.center)
            .padding()
        }
        .frame(width: cardWidth, height: cardHeight)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    MoodRoomCardView(room: MoodRoom(name: "Test", schedule: "Daily", background: "MoodRoomHappy"))
}
