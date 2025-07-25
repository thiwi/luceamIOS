import SwiftUI
import Charts

struct StatsView: View {
    enum Period: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"

        var id: Self { self }
    }

    struct StatsEntry: Identifiable {
        var date: Date
        var moments: Double
        var moods: Double
        var id: Date { date }
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var stats: StatsStore

    @State private var period: Period = .day

    var body: some View {
        NavigationStack {
            ZStack {
                Image("DetailViewBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Picker("Period", selection: $period) {
                        ForEach(Period.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    chart
                        .frame(height: 220)
                        .animation(.default, value: period)
                    summary
                }
                .frame(maxWidth: .infinity)
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
    }

    private var summary: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Moments created")
                Spacer()
                Text("\(stats.momentsCreated)")
            }
            HStack {
                Text("Mood rooms created")
                Spacer()
                Text("\(stats.moodRoomsCreated)")
            }
        }
        .padding()
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
        .padding([.horizontal, .bottom])
    }

    private var chart: some View {
        Chart(aggregatedData) { entry in
            BarMark(
                x: .value("Date", entry.date, unit: unitForPeriod()),
                y: .value("Minutes in moments", entry.moments / 60)
            )
            .foregroundStyle(Color.blue.gradient)

            BarMark(
                x: .value("Date", entry.date, unit: unitForPeriod()),
                y: .value("Minutes in mood rooms", entry.moods / 60)
            )
            .foregroundStyle(Color.purple.gradient)
        }
    }

    private func unitForPeriod() -> Calendar.Component {
        switch period {
        case .day: return .day
        case .week: return .weekOfYear
        case .month: return .month
        }
    }

    private var aggregatedData: [StatsEntry] {
        let df = StatsStore.dayFormatter
        let calendar = Calendar.current

        var dayMoments: [Date: Double] = [:]
        for (k, v) in stats.dailyMoments {
            if let d = df.date(from: k) { dayMoments[d] = v }
        }
        var dayMoods: [Date: Double] = [:]
        for (k, v) in stats.dailyMoodRooms {
            if let d = df.date(from: k) { dayMoods[d] = v }
        }
        let allDates = Set(dayMoments.keys).union(dayMoods.keys)

        switch period {
        case .day:
            return allDates.sorted().map { date in
                StatsEntry(date: date,
                           moments: dayMoments[date] ?? 0,
                           moods: dayMoods[date] ?? 0)
            }
        case .week:
            var groups: [Date: (Double, Double)] = [:]
            for date in allDates {
                let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                let start = calendar.date(from: comps) ?? date
                var tuple = groups[start] ?? (0, 0)
                tuple.0 += dayMoments[date] ?? 0
                tuple.1 += dayMoods[date] ?? 0
                groups[start] = tuple
            }
            return groups.keys.sorted().map { date in
                let val = groups[date]!
                return StatsEntry(date: date, moments: val.0, moods: val.1)
            }
        case .month:
            var groups: [Date: (Double, Double)] = [:]
            for date in allDates {
                let comps = calendar.dateComponents([.year, .month], from: date)
                let start = calendar.date(from: comps) ?? date
                var tuple = groups[start] ?? (0, 0)
                tuple.0 += dayMoments[date] ?? 0
                tuple.1 += dayMoods[date] ?? 0
                groups[start] = tuple
            }
            return groups.keys.sorted().map { date in
                let val = groups[date]!
                return StatsEntry(date: date, moments: val.0, moods: val.1)
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView().environmentObject(StatsStore())
    }
}
