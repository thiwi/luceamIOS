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
                let textColor = room.background == "MoodRoomNight" ? Color.white : Color.black
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
    }
}

#Preview {
    MoodRoomCardView(room: MoodRoom(name: "Test", schedule: "Daily", background: "MoodRoomHappy", durationMinutes: 30, isActive: true))
}
