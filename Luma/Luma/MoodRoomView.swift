import SwiftUI

struct MoodRoomView: View {
    let name: String
    var background: String = "MoodRoomHappy"
    @Environment(\.dismiss) private var dismiss

    var onCreate: (() -> Void)? = nil
    var onDiscard: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Image(onCreate != nil || onDiscard != nil ? "startscreen" : "DetailViewBackground")
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

                ZStack {
                    Text(name)
                        .font(.title)
                        .foregroundColor(textColor)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            Image(background)
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

                if onCreate != nil || onDiscard != nil {
                    HStack {
                        if let onDiscard { Button("Discard") { onDiscard() }.foregroundColor(.black) }
                        Spacer()
                        if let onCreate { Button("Create") { onCreate() }.foregroundColor(.black) }
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    MoodRoomView(name: "Test Room")
}
