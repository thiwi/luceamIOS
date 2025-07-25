import SwiftUI

struct MoodRoomView: View {
    let room: MoodRoom
    var isPreview: Bool = false
    var isOwnRoom: Bool = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var stats: StatsStore

    @State private var people = 0
    @State private var closeWork: DispatchWorkItem?
    @State private var now = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var onCreate: (() -> Void)? = nil
    var onDiscard: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Image("DetailViewBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {

                let textColor = room.background == "MoodRoomNight" ? Color.white : Color.black

                Text("Mood room")
                    .font(.headline)
                    .foregroundColor(textColor)
                Text("\(room.schedule) | \(remainingTimeText)")
                    .font(.footnote)
                    .foregroundColor(textColor)
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

                    if isOwnRoom {
                        Text(people == 1 ?
                             "There is 1 person with you in this mood room." :
                             "There are \(people) persons with you in this mood room.")
                            .font(.footnote)
                            .foregroundColor(textColor)
                            .padding(8)
                    }
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
            if isOwnRoom {
                people = 0
                incrementPeople()
            }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                }
            }
        }
    }

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

    private func scheduleClose() {
        let closeTime = room.startTime.addingTimeInterval(TimeInterval(room.durationMinutes * 60))
        let remaining = closeTime.timeIntervalSince(Date())
        guard remaining > 0 else {
            dismiss()
            return
        }
        let work = DispatchWorkItem { dismiss() }
        closeWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining, execute: work)
    }

    private var remainingTimeText: String {
        let remaining = room.closeTime.timeIntervalSince(now)
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
    MoodRoomView(room: MoodRoom(name: "Test Room",
                                schedule: "Once",
                                background: "MoodRoomHappy",
                                startTime: Date(),
                                createdAt: Date(),
                                durationMinutes: 15),
                 isPreview: true)
}
