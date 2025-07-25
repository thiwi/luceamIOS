import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            GeometryReader { proxy in
                Image("startscreen")
                    .resizable()
                    .scaledToFit()
                    .frame(height: proxy.size.height)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}
