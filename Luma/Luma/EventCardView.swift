import SwiftUI

struct EventCardView: View {
    let event: Event
    @State private var hovering = false

    var body: some View {
        ZStack {
            Image("CardBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .cornerRadius(16)
            Text(event.content)
                .font(.title)
                .foregroundColor(.black)
                .padding()
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .scaleEffect(hovering ? 1.05 : 1)
        .animation(.easeInOut(duration: 0.2), value: hovering)
        .onHover { hovering = $0 }
    }
}

#Preview {
    EventCardView(event: Event(id: 1, content: "Hello world", mood: nil, symbol: nil))
}
