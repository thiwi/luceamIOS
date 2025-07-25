import SwiftUI

struct MoodRoomView: View {
    let name: String
    var background: String = "MoodRoomHappy"
    var isPreview: Bool = false
    var isOwnRoom: Bool = false
    @Environment(\.dismiss) private var dismiss

    @State private var people = 0

    var onCreate: (() -> Void)? = nil
    var onDiscard: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Image("DetailViewBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding()

                let textColor = background == "MoodRoomNight" ? Color.white : Color.black

                Text("Mood room")
                    .font(.headline)
                    .foregroundColor(textColor)
                    .padding(.bottom, 8)

                Spacer()

                ZStack {
                    Image(background)
                        .resizable()
                        .aspectRatio(contentMode: .fill)

                    VStack {
                        Text(name)
                            .font(.title2)
                            .foregroundColor(textColor)
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                }
                .frame(width: UIScreen.main.bounds.width * 0.95,
                       height: UIScreen.main.bounds.height * 0.7)
                .cornerRadius(16)
                .clipped()
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
                .padding()

                if isOwnRoom {
                    Text("There are \(people) people with you in this room.")
                        .font(.footnote)
                        .foregroundColor(textColor)
                        .padding(6)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                }

                if onCreate != nil || onDiscard != nil {
                    HStack {
                        if let onDiscard { Button("Discard") { onDiscard() }.foregroundColor(.black) }
                        Spacer()
                        if let onCreate { Button("Create") { onCreate() }.foregroundColor(.black) }
                    }
                    .padding()
                } else if isPreview {
                    Text("Swipe down to close preview.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                } else {
                    Text("Use the back button to leave this room.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                Spacer()
            }
        }
        .onAppear {
            guard isOwnRoom else { return }
            people = 0
            incrementPeople()
        }
        .interactiveDismissDisabled(!isPreview)
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
    MoodRoomView(name: "Test Room", isPreview: true)
}
