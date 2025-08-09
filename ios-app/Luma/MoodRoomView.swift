import SwiftUI

/// Full screen representation of a ``MoodRoom``.
struct MoodRoomView: View {
    /// Room configuration to display.
    let room: MoodRoom

    /// Indicates preview mode without presence tracking.
    var isPreview: Bool = false

    /// Marks the room as created by the current user.
    var isOwnRoom: Bool = false

    /// Used to dismiss the screen when finished.
    @Environment(\.dismiss) private var dismiss

    /// Statistics store recording time spent in rooms.
    @EnvironmentObject var stats: StatsStore


    /// Work item scheduled to auto-close the room.
    @State private var closeWork: DispatchWorkItem?

    /// Current timestamp for calculating remaining time.
    @State private var now = Date()

    /// Timer that fires each minute to update `now`.
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    /// Callbacks for preview creation flow.
    var onCreate: (() -> Void)? = nil
    var onDiscard: (() -> Void)? = nil

    /// Displays the room background, remaining time and participant count.
    var body: some View {
        ZStack {
            Image("DetailViewBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {

                let textColor = room.textColor

                Text("Mood room")
                    .font(.headline)
                    .foregroundColor(.black)
                Text("\(room.schedule) | \(remainingTimeText)")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .padding(.bottom, 8)

                Spacer()

                ZStack(alignment: .bottom) {
                    Image(room.background)
                        .resizable()
                        .aspectRatio(contentMode: .fill)

                    VStack {
                        Spacer()
                        Text(room.name)
                            .font(.title2)
                            .foregroundColor(textColor)
                        Spacer()
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                }
                .frame(width: UIScreen.main.bounds.width * 0.95,
                       height: UIScreen.main.bounds.height * 0.7)
                .cornerRadius(16)
                .clipped()
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
                .padding()

                if onCreate != nil || onDiscard != nil {
                    HStack {
                        if let onDiscard { Button("Discard") { onDiscard() }.foregroundColor(.black) }
                        Spacer()
                        if let onCreate { Button("Create") { onCreate() }.foregroundColor(.black) }
                    }
                    .padding()
                } else if isPreview {
                    Text("Swipe down to close preview.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                } else {
                    Spacer().frame(height: 20)
                }
                Spacer()
            }
        }
        .onAppear {
            scheduleClose()
            stats.startMoodRoom(background: room.background, schedule: room.schedule)
        }
        .onDisappear {
            closeWork?.cancel()
            stats.endMoodRoom()
        }
        .interactiveDismissDisabled(!isPreview)
        .onReceive(timer) { _ in
            now = Date()
        }
    }

    /// Schedules automatic dismissal when the room's time expires.
    private func scheduleClose() {
        let closeTime = room.currentCloseTime
        let remaining = closeTime.timeIntervalSince(Date())
        guard remaining > 0 else {
            dismiss()
            return
        }
        let work = DispatchWorkItem { dismiss() }
        closeWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining, execute: work)
    }

    /// Human readable string describing how much time is left.
    private var remainingTimeText: String {
        let remaining = room.currentCloseTime.timeIntervalSince(now)
        guard remaining > 0 else { return "Less than 1 minute left" }
        if remaining < 60 {
            return "Less than 1 minute left"
        }
        let minutes = Int(remaining / 60)
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            if mins > 0 {
                return "\(hours)h \(mins)min left"
            } else {
                return "\(hours)h left"
            }
        } else {
            return "\(mins)min left"
        }
    }
}

#Preview {
    // Preview instance used in the Xcode canvas.
    MoodRoomView(room: MoodRoom(name: "Test Room",
                                schedule: "Once",
                                background: "MoodRoomHappy",
                                textColor: .black,
                                startTime: Date(),
                                createdAt: Date(),
                                durationMinutes: 15),
                 isPreview: true)
        .environmentObject(StatsStore())
}
