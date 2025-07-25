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
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
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
                    Picker("Year", selection: $selectedYear) {
                        ForEach(availableYears, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                    let _ = print("aggregatedData.count = \(aggregatedData.count)")
                    if !aggregatedData.isEmpty {
                        chart
                            .frame(height: 220)
                            .animation(.default, value: period)
                            .animation(.default, value: selectedYear)
                    } else {
                        Text("No data available")
                            .frame(height: 220)
                    }
                    summary
                }
                .frame(maxWidth: .infinity)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
        Chart {
            ForEach(aggregatedData) { entry in
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
    }

    private func unitForPeriod() -> Calendar.Component {
        switch period {
        case .day: return .day
        case .week: return .weekOfYear
        case .month: return .month
        }
    }

    private var availableYears: [Int] {
        let df = StatsStore.dayFormatter
        let calendar = Calendar.current
        let momentYears = stats.dailyMoments.keys.compactMap { key -> Int? in
            guard let date = df.date(from: key) else { return nil }
            return calendar.component(.year, from: date)
        }
        let moodYears = stats.dailyMoodRooms.keys.compactMap { key -> Int? in
            guard let date = df.date(from: key) else { return nil }
            return calendar.component(.year, from: date)
        }
        return Array(Set(momentYears + moodYears)).sorted()
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
        let filteredDates = allDates.filter { calendar.component(.year, from: $0) == selectedYear }

        switch period {
        case .day:
            return filteredDates.sorted().map { date in
                StatsEntry(date: date,
                           moments: dayMoments[date] ?? 0,
                           moods: dayMoods[date] ?? 0)
            }
        case .week:
            var groups: [Date: (Double, Double)] = [:]
            for date in filteredDates {
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
            for date in filteredDates {
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
        StatsView().environmentObject(StatsStore.sample)
    }
}
