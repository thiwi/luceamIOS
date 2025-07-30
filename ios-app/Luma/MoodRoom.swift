import Foundation
import SwiftUI

/// Data model representing a scheduled mood room.
///
/// Mood rooms can recur daily or on specific weekdays. Timing
/// properties are stored as absolute values but convenience
/// accessors adjust them to the current day for comparisons.
struct MoodRoom: Identifiable, Hashable, Codable {
    /// Unique identifier for the mood room.
    var id = UUID()

    /// Display name shown to the user.
    var name: String

    /// Schedule string such as "Every Monday at 17:30" or "Once".
    var schedule: String

    /// Image asset name for the background.
    var background: String

    /// Text color used when rendering overlays.
    var textColor: Color = .black

    /// First start time for the room.
    var startTime: Date

    /// Creation timestamp for analytics.
    var createdAt: Date

    /// Duration in minutes for each session.
    var durationMinutes: Int

    /// Session token of the creator when loaded from the backend.
    var sessionToken: String? = nil

    /// End time calculated from the start time and duration.
    var closeTime: Date { startTime.addingTimeInterval(TimeInterval(durationMinutes * 60)) }

    /// Start time adjusted for today if the room is recurring.
    var currentStartTime: Date {
        if schedule.lowercased().hasPrefix("once") { return startTime }
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: startTime)
        return cal.date(bySettingHour: comps.hour ?? 0,
                        minute: comps.minute ?? 0,
                        second: 0,
                        of: Date()) ?? startTime
    }

    /// Close time for the current occurrence.
    var currentCloseTime: Date {
        currentStartTime.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }

    /// Returns `true` when the room is currently active and can be joined.
    var isJoinable: Bool {
        let now = Date()
        let cal = Calendar.current

        // Once-off rooms use the exact start and close times
        if schedule.lowercased().hasPrefix("once") {
            return now >= startTime && now <= closeTime
        }

        // Check weekday for recurring schedules like "Every Mon, Tue" or "Daily"
        // and verify today matches the configured days.
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
        let startToday = currentStartTime
        let endToday = currentCloseTime
        return now >= startToday && now <= endToday
    }
}

extension MoodRoom {
    enum CodingKeys: String, CodingKey {
        case id, name, schedule, background, textColor, startTime, createdAt, durationMinutes, sessionToken
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        schedule = try container.decode(String.self, forKey: .schedule)
        background = try container.decode(String.self, forKey: .background)
        let color = try container.decodeIfPresent(String.self, forKey: .textColor) ?? "black"
        textColor = color.lowercased() == "white" ? .white : .black
        startTime = try container.decode(Date.self, forKey: .startTime)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        sessionToken = try container.decodeIfPresent(String.self, forKey: .sessionToken)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(background, forKey: .background)
        try container.encode(textColor == .white ? "white" : "black", forKey: .textColor)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(durationMinutes, forKey: .durationMinutes)
        try container.encodeIfPresent(sessionToken, forKey: .sessionToken)
    }
}
