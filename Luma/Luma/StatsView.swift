import SwiftUI

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var stats: StatsStore

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                Image("DetailViewBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                table
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.black)
                }
            }
        }
        .onReceive(timer) { _ in }
    }

    private var table: some View {
        VStack(alignment: .leading, spacing: 8) {
            statRow("Time in moments", format(seconds: stats.timeInMoments))
            statRow("Moments created", "\(stats.momentsCreated)")
            Divider()
            Text("Time in mood rooms")
                .font(.headline)
            ForEach(sortedMoodKeys, id: \.self) { key in
                statRow(prettyMoodKey(key), format(seconds: stats.timeInMoodRooms[key] ?? 0))
            }
            Divider()
            statRow("Mood rooms created", "\(stats.moodRoomsCreated)")
        }
        .padding()
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
        .padding()
    }

    private func statRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }

    private var sortedMoodKeys: [String] {
        stats.timeInMoodRooms.keys.sorted()
    }

    private func prettyMoodKey(_ key: String) -> String {
        let parts = key.split(separator: "-")
        guard parts.count == 2 else { return key }
        let bg = String(parts[0])
        let rec = parts[1] == "recurring" ? "recurring" : "once"
        return "\(bg) (\(rec))"
    }

    private func format(seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)min"
        } else {
            return "\(mins)min"
        }
    }
}
