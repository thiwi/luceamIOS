import SwiftUI

struct EventCardView: View {
    let event: Event
    let background: String
    @State private var hovering = false

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
        .scaleEffect(hovering ? 1.05 : 1)
        .animation(.easeInOut(duration: 0.2), value: hovering)
        .onHover { hovering = $0 }
    }
}

#Preview {
    EventCardView(event: Event(id: 1, content: "Hello world", mood: nil, symbol: nil), background: "card_background1")
}
