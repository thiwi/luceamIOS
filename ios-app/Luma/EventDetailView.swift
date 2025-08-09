import SwiftUI

/// Full screen view showing a single moment in detail.
struct EventDetailView: View {
    /// Event being displayed.
    let event: Event

    /// Indicates whether this event belongs to the current session.
    var isOwnEvent: Bool = false

    /// Used to close the sheet.
    @Environment(\.dismiss) private var dismiss

    /// Live participant count fetched from the backend.
    @State private var count: Int? = nil
    private let presence = PresenceClient()
    @State private var presenceTask: Task<Void, Never>? = nil
    @State private var pollTimer: Timer?

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
                Text(countText)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
                Spacer()
            }
        }
        .onAppear {
            stats.startMoment()
            startPresence()
        }
        .onDisappear {
            stats.endMoment()
            stopPresence()
        }
    }

    /// Starts fetching and subscribing to presence counts.
    private func startPresence() {
        presenceTask = Task {
            if let c = await presence.fetchPresence(momentId: event.id) {
                await MainActor.run { count = c }
            }
            for await c in presence.subscribePresence(momentId: event.id) {
                await MainActor.run { count = c }
            }
        }
        pollTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
            Task {
                if let c = await presence.fetchPresence(momentId: event.id) {
                    await MainActor.run { count = c }
                }
            }
        }
    }

    /// Cancels presence subscriptions and timers.
    private func stopPresence() {
        presenceTask?.cancel()
        presenceTask = nil
        pollTimer?.invalidate()
        pollTimer = nil
    }

    /// Human readable count text.
    private var countText: String {
        guard let c = count else { return "—" }
        return c == 1 ?
            "There is 1 person with you in this moment." :
            "There are \(c) persons with you in this moment."
    }
}

#Preview {
    // Preview used in SwiftUI canvas.
    EventDetailView(event: Event(id: UUID().uuidString,
                                 content: "Sample moment",
                                 mood: nil,
                                 symbol: nil))
}
