import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            Image("startscreen")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}
