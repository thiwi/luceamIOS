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
            GeometryReader { geo in
                VStack(spacing: 16) {
                    Picker("Period", selection: $period) {
                        ForEach(Period.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                    Picker("Year", selection: $selectedYear) {
                        ForEach(availableYears, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)

                    Group {
                        if !aggregatedData.isEmpty {
                            chart(in: geo)
                                .frame(height: 220)
                                .animation(.default, value: period)
                                .animation(.default, value: selectedYear)
                        } else {
                            Text("No data available")
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .onAppear {
                        print("aggregatedData.count = \(aggregatedData.count)")
                        if !availableYears.contains(selectedYear) {
                            selectedYear = availableYears.last ?? selectedYear
                        }
                    }

                    summary
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                .padding()
                .background(
                    Image("DetailViewBackground")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
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
    }

    private func chart(in geo: GeometryProxy) -> some View {
        let maxValue = aggregatedData
            .map { max($0.moments, $0.moods) / 60 }
            .max() ?? 0

        return ScrollView(.horizontal, showsIndicators: false) {
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
            .chartYScale(domain: 0...maxValue)
            .frame(minWidth: geo.size.width - 32)
            .padding(.horizontal, 16)
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
            if let d = df.date(from: k) {
                let date = calendar.startOfDay(for: d)
                dayMoments[date] = v
            }
        }

        var dayMoods: [Date: Double] = [:]
        for (k, v) in stats.dailyMoodRooms {
            if let d = df.date(from: k) {
                let date = calendar.startOfDay(for: d)
                dayMoods[date] = v
            }
        }

        switch period {
        case .day:
            let today = calendar.startOfDay(for: Date())
            guard let start = calendar.date(byAdding: .day, value: -6, to: today) else { return [] }
            return (0..<7).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
                let m = dayMoments[date] ?? 0
                let mood = dayMoods[date] ?? 0
                return StatsEntry(date: date, moments: m, moods: mood)
            }

        case .week:
            var grouped: [Date: (Double, Double)] = [:]
            for date in Set(dayMoments.keys).union(dayMoods.keys) {
                if calendar.component(.yearForWeekOfYear, from: date) == selectedYear {
                    let startWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
                    var tuple = grouped[startWeek] ?? (0, 0)
                    tuple.0 += dayMoments[date] ?? 0
                    tuple.1 += dayMoods[date] ?? 0
                    grouped[startWeek] = tuple
                }
            }

            let currentYear = calendar.component(.yearForWeekOfYear, from: Date())
            let firstWeek = calendar.date(from: DateComponents(calendar: calendar, weekOfYear: 1, yearForWeekOfYear: selectedYear))!
            let weekCount: Int = {
                if selectedYear == currentYear {
                    return calendar.component(.weekOfYear, from: Date())
                } else {
                    return calendar.range(of: .weekOfYear, in: .yearForWeekOfYear, for: firstWeek)?.count ?? 52
                }
            }()

            return (1...weekCount).compactMap { w in
                guard let start = calendar.date(from: DateComponents(calendar: calendar, weekOfYear: w, yearForWeekOfYear: selectedYear)) else { return nil }
                let tuple = grouped[start] ?? (0, 0)
                return StatsEntry(date: start, moments: tuple.0, moods: tuple.1)
            }

        case .month:
            var grouped: [Date: (Double, Double)] = [:]
            for date in Set(dayMoments.keys).union(dayMoods.keys) {
                if calendar.component(.year, from: date) == selectedYear {
                    let comps = calendar.dateComponents([.year, .month], from: date)
                    let startMonth = calendar.date(from: comps) ?? date
                    var tuple = grouped[startMonth] ?? (0, 0)
                    tuple.0 += dayMoments[date] ?? 0
                    tuple.1 += dayMoods[date] ?? 0
                    grouped[startMonth] = tuple
                }
            }

            let currentYear = calendar.component(.year, from: Date())
            let monthCount = selectedYear == currentYear ? calendar.component(.month, from: Date()) : 12

            return (1...monthCount).compactMap { m in
                guard let start = calendar.date(from: DateComponents(calendar: calendar, year: selectedYear, month: m)) else { return nil }
                let tuple = grouped[start] ?? (0, 0)
                return StatsEntry(date: start, moments: tuple.0, moods: tuple.1)
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView().environmentObject(StatsStore.sample)
    }
}
