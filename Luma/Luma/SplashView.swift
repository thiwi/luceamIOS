import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool

    var body: some View {
        ZStack {
            Image("startscreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                Spacer()
                Button(action: { showSplash = false }) {
                    Label("Get Started", systemImage: "sun.max.fill")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}
