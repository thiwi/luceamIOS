import SwiftUI

struct EventDetailView: View {
    let event: Event
    let background: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image("day_splash_final2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()
                ZStack {
                    Image(background)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                    Text(event.content)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .multilineTextAlignment(.center)
                        .shadow(radius: 4)
                }
                .padding()
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
    EventDetailView(event: MockData.events.first!, background: "card_background1")
}
