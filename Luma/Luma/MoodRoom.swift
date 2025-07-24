import Foundation
import SwiftUI

struct MoodRoom: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let schedule: String
    let background: String
    let startTime: Date
    let createdAt: Date
    var durationMinutes: Int

    var isJoinable: Bool {
        let closeTime = startTime.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return Date() >= startTime && Date() <= closeTime
    }
}
