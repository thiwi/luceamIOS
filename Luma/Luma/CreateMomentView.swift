import SwiftUI

struct CreateMomentView: View {
    @Binding var text: String
    var onCreate: (String) -> Void
    var onDiscard: () -> Void

    var body: some View {
        VStack {
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
            .frame(width: UIScreen.main.bounds.width * 0.95,
                   height: UIScreen.main.bounds.height * 0.6)
            .cornerRadius(16)
            .clipped()
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
            .padding()

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .frame(height: 100)
                .padding([.horizontal])

            HStack {
                Button("Discard") { onDiscard() }
                    .padding()
                Spacer()
                Button("Create") { onCreate(text) }
                    .padding()
            }
        }
    }
}

#Preview {
    CreateMomentView(text: .constant("")) { _ in } onDiscard: {}
}
