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
        Date() >= startTime && Date() <= closeTime
    }
}
