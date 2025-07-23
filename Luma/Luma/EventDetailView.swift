import SwiftUI

struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Spacer()
                Text(event.content)
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
            }
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .padding()
        }
    }
}

#Preview {
    EventDetailView(event: MockData.events.first!)
}
