import SwiftUI

struct MoodRoomView: View {
    let room: MoodRoom
    var isPreview: Bool = false
    var isOwnRoom: Bool = false
    @Environment(\.dismiss) private var dismiss

    @State private var people = 0
    @State private var closeWork: DispatchWorkItem?

    var onCreate: (() -> Void)? = nil
    var onDiscard: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Image("DetailViewBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("Leave mood room")
                                .font(.callout)
                        }
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding()

                let textColor = room.background == "MoodRoomNight" ? Color.white : Color.black

                Text("Mood room")
                    .font(.headline)
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
                            .padding(6)
                            .background(Color.black)
                            .cornerRadius(8)
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
        }
        .onDisappear {
            closeWork?.cancel()
        }
        .interactiveDismissDisabled(!isPreview)
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
