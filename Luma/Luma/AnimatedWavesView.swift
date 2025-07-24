import SwiftUI

struct Wave: Shape {
    var phase: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waveHeight: CGFloat = 20
        let wavelength = rect.width / 1.5

        path.move(to: .zero)
        for x in stride(from: 0, to: rect.width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin(relativeX * 2 * .pi + phase)
            let y = waveHeight * sine + rect.height / 2
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
        ZStack {
            Color(.systemBackground)

            ForEach(0..<6) { i in
                Wave(phase: phase + CGFloat(i) * 0.5)
                    .fill(Color(white: 0.9 - Double(i) * 0.05))
                    .frame(height: 300)
                    .offset(y: CGFloat(i * 25))
            }
        }
        .ignoresSafeArea()
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
