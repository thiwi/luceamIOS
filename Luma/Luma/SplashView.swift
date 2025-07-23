import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool

    var body: some View {
        ZStack {
            Image("startscreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}
