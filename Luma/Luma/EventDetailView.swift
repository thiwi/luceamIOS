import SwiftUI

struct EventDetailView: View {
    let event: Event
    let background: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("day_splash_final2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding()
                }

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
                Text("You are now in this moment")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                Spacer()
            }
        }
    }
}

#Preview {
    EventDetailView(event: MockData.events.first!, background: "card_background1")
}
