import SwiftUI

/// Sheet for composing a new moment event.
struct CreateMomentView: View {
    @EnvironmentObject var sessionStore: SessionStore

    /// Two-way binding for the user's typed text.
    @Binding var text: String

    /// Maximum characters allowed in the text field.
    private let maxLength = 100

    /// Scale factor applied to the preview card so the action buttons sit higher
    /// on the screen.
    private let cardScale: CGFloat = 0.75

    /// Called when the user confirms creation.
    var onCreate: (String) -> Void

    /// Called when the user discards the moment.
    var onDiscard: () -> Void

    /// Main UI with a card preview and text editor.
    var body: some View {
        VStack {
            Text("Create a new moment")
                .font(.headline)
                .padding()
            ZStack {
                Image("OwnMoment")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                Text(text)
                    .font(.title)
                    .foregroundColor(.black)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            .frame(width: UIScreen.main.bounds.width * 0.95 * cardScale,
                   height: UIScreen.main.bounds.height * 0.6 * cardScale)
            .cornerRadius(16)
            .clipped()
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
            .padding()

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Enter new moment")
                        .foregroundColor(.gray)
                        .padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                }
                TextEditor(text: $text)
                    .onChange(of: text) { newValue in
                        if newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
                    .scrollContentBackground(.hidden)
            }
            .frame(height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4))
            )
            .padding([.horizontal])

            HStack {
                Spacer()
                Text("\(maxLength - text.count) characters left")
                    .font(.caption2)
                    .foregroundColor(Color(.darkGray))
            }
            .padding(.horizontal)

            HStack {
                Button("Discard") { onDiscard() }
                    .padding()
                Spacer()
                Button("Create") {
                    if sessionStore.token != nil {
                        onCreate(text.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        print("❌ No session token available")
                    }
                }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding()
            }
        }
    }
}

#Preview {
    // Preview with an empty text binding.
    CreateMomentView(text: .constant("")) { _ in } onDiscard: {}
        .environmentObject(SessionStore())
}
