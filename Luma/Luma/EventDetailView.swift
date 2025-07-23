import SwiftUI

struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("DetailViewBackground")
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
                Text("You are no in this moment.")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 8)

                ZStack {
                    Text(event.content)
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            Image("CardBackground")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        )
                }
                .frame(width: UIScreen.main.bounds.width * 0.95,
                       height: UIScreen.main.bounds.height * 0.7)
                .cornerRadius(16)
                .clipped()
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
                .padding()
                Text("Swipe down to leave this moment.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                Spacer()
            }
        }
    }
}

#Preview {
    EventDetailView(event: MockData.events.first!)
}
