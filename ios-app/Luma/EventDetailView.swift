import SwiftUI

/// Full screen view showing a single moment in detail.
struct EventDetailView: View {
    /// Event being displayed.
    let event: Event

    /// Indicates whether this event belongs to the current session.
    var isOwnEvent: Bool = false

    /// Used to close the sheet.
    @Environment(\.dismiss) private var dismiss

    /// Simulated participant count for the preview.
    @State private var people = 0

    /// Statistics store to track time spent.
    @EnvironmentObject var stats: StatsStore

    /// Complete modal screen for an individual moment.
    var body: some View {
        ZStack {
            Image("DetailViewBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding()
                }

                Spacer()
                Text("You are now in this moment.")
                    .font(.headline)
                    .foregroundColor(Color(.darkGray))
                    .padding(.bottom, 8)

                ZStack {
                    if isOwnEvent {
                        Image("OwnMoment")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image("CardBackground")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    Text(event.content)
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: UIScreen.main.bounds.width * 0.95,
                       height: UIScreen.main.bounds.height * 0.7)
                .cornerRadius(16)
                .clipped()
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
                .padding()
                if isOwnEvent {
                    Text(people == 1 ?
                         "There is 1 person with you in this moment." :
                         "There are \(people) persons with you in this moment.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                } else {
                    Text("Swipe down to leave this moment.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                Spacer()
            }
        }
        // Start counting time and simulate participants when
        // the view appears.
        .onAppear {
            stats.startMoment()
            guard isOwnEvent else { return }
            people = 0
            incrementPeople()
        }
        // Persist time spent once the view is dismissed.
        .onDisappear {
            stats.endMoment()
        }
    }

    /// Adds random participants over time to simulate activity in
    /// the preview and statistics demo.
    private func incrementPeople() {
        guard people < 15 else { return }
        let delay = Double.random(in: 0...5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let addition = Int.random(in: 1...3)
            people = min(15, people + addition)
            if people < 15 {
                incrementPeople()
            }
        }
    }
}

#Preview {
    // Preview used in SwiftUI canvas.
    EventDetailView(event: Event(id: UUID().uuidString,
                                 content: "Sample moment",
                                 mood: nil,
                                 symbol: nil))
}
