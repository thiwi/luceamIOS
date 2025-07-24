import SwiftUI

struct Wave: Shape {
    var phase: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waveHeight: CGFloat = 20
        let wavelength = rect.width / 1.5

        path.move(to: CGPoint(x: 0, y: 0))
        for x in stride(from: 0, to: rect.width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin(relativeX * 2 * .pi + phase)
            let y = waveHeight * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
}

struct AnimatedWavesView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                let gradient = LinearGradient(colors: [
                    Color(red: 0.96, green: 0.89, blue: 0.76),
                    Color(red: 0.93, green: 0.80, blue: 0.66)
                ], startPoint: .top, endPoint: .bottom)

                gradient

                ForEach(0..<6) { i in
                    Wave(phase: phase + CGFloat(i) * 0.5)
                        .fill(gradient)
                        .frame(height: geo.size.height)
                        .offset(y: CGFloat(i * 25) - geo.size.height / 2)
                }
            }
            .clipped()
        }
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

#Preview {
    AnimatedWavesView()
}
