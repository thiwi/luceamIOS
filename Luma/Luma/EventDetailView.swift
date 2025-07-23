import SwiftUI

struct EventDetailView: View {
    let event: Event
    var isOwnEvent: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var people = 0

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
                Text("You are now in this moment.")
                    .font(.headline)
                    .foregroundColor(Color(.darkGray))
                    .padding(.bottom, 8)

                ZStack {
                    Text(event.content)
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            Image(isOwnEvent ? "OwnMoment" : "CardBackground")
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
                if isOwnEvent {
                    Text("There are \(people) people with you in this moment.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                } else {
                    Text("Swipe down to leave this moment.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                Spacer()
            }
        }
        .onAppear {
            guard isOwnEvent else { return }
            people = 0
            incrementPeople()
        }
    }

    private func incrementPeople() {
        guard people < 15 else { return }
        let delay = Double.random(in: 0...5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let addition = Int.random(in: 1...3)
            people = min(15, people + addition)
            if people < 15 {
                incrementPeople()
            }
        }
    }
}

#Preview {
    EventDetailView(event: MockData.events.first!)
}
