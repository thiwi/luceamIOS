import SwiftUI

struct EventCardView: View {
    let event: Event
    @State private var hovering = false

    var body: some View {
        let cardWidth = UIScreen.main.bounds.width * 0.95
        let cardHeight = UIScreen.main.bounds.height * 0.3

        return ZStack {
            Image("CardBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: cardWidth, height: cardHeight)
                .clipped()
                .cornerRadius(16)
            Text(event.content)
                .font(.title)
                .foregroundColor(.black)
                .padding()
                .multilineTextAlignment(.center)
        }
        .frame(width: cardWidth, height: cardHeight)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
        .scaleEffect(hovering ? 1.05 : 1)
        .animation(.easeInOut(duration: 0.2), value: hovering)
        .onHover { hovering = $0 }
    }
}

#Preview {
    EventCardView(event: Event(id: 1, content: "Hello world", mood: nil, symbol: nil))
}
