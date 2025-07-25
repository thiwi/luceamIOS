import SwiftUI

/// Simple splash screen shown on launch.
struct SplashView: View {
    /// Binding used to hide the splash after animation.
    @Binding var showSplash: Bool

    /// Full screen image overlaying a black background.
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image("startscreen")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity, alignment: .center)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    // Quick preview of the splash screen.
    SplashView(showSplash: .constant(true))
}
