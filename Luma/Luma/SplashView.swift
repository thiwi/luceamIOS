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
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity, alignment: .center)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}
