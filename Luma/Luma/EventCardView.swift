import SwiftUI

struct EventCardView: View {
    let event: Event
    let background: String

    var body: some View {
        ZStack {
            Image(background)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .clipped()
                .cornerRadius(16)
            Text(event.content)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .multilineTextAlignment(.center)
                .shadow(radius: 4)
        }
    }
}

#Preview {
    EventCardView(event: Event(id: 1, content: "Hello world", mood: nil, symbol: nil), background: "card_background1")
}
