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
                ZStack {
                    Image("CardBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                        .clipped()
                        .cornerRadius(16)

                    VStack {
                        Text("You are now in this moment")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.top, 16)
                        Spacer()
                    }

                    Text(event.content)
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                .padding()
                Text("Swipe done to leave this moment")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                Spacer()
            }
        }
    }
}

#Preview {
    EventDetailView(event: MockData.events.first!)
}
