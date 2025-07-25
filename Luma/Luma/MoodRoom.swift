import Foundation
import SwiftUI

struct MoodRoom: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var schedule: String
    var background: String
    var startTime: Date
    var createdAt: Date
    var durationMinutes: Int

    var closeTime: Date { startTime.addingTimeInterval(TimeInterval(durationMinutes * 60)) }

    var isJoinable: Bool {
        let now = Date()
        let cal = Calendar.current

        // Once-off rooms use the exact start and close times
        if schedule.lowercased().hasPrefix("once") {
            return now >= startTime && now <= closeTime
        }

        // Check weekday for recurring schedules like "Every Mon, Tue" or "Daily"
        if schedule.lowercased().hasPrefix("every ") {
            if let range = schedule.range(of: " at ") {
                let daysPart = schedule[schedule.index(schedule.startIndex, offsetBy: 6)..<range.lowerBound]
                let dayTokens = daysPart.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                if !dayTokens.isEmpty {
                    let idx = cal.component(.weekday, from: now) - 1 // 0 = Sunday
                    let todayFull = cal.weekdaySymbols[idx].lowercased()
                    let todayShort = String(todayFull.prefix(3))
                    let matches = dayTokens.contains(where: { token in
                        token.hasPrefix(todayFull) || token.hasPrefix(todayShort)
                    })
                    if !matches { return false }
                }
            }
        }

        // Daily schedules and matching weekdays use today's time components
        let comps = cal.dateComponents([.hour, .minute], from: startTime)
        guard let startToday = cal.date(bySettingHour: comps.hour ?? 0,
                                        minute: comps.minute ?? 0,
                                        second: 0,
                                        of: now) else { return false }
        let endToday = startToday.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return now >= startToday && now <= endToday
    }
}
