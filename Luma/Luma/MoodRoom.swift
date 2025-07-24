import Foundation
import SwiftUI

struct MoodRoom: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let schedule: String
    let background: String
    var durationMinutes: Int
    var isActive: Bool
}
