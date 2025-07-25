import Foundation
import SwiftUI

@MainActor
class StatsStore: ObservableObject {
    @Published var timeInMoments: TimeInterval
    @Published var timeInMoodRooms: [String: TimeInterval]
    @Published var momentsCreated: Int
    @Published var moodRoomsCreated: Int

    private var momentStart: Date?
    private var moodStart: Date?
    private var currentMoodKey: String?

    init() {
        self.timeInMoments = UserDefaults.standard.double(forKey: "timeInMoments")
        self.timeInMoodRooms = (UserDefaults.standard.dictionary(forKey: "timeInMoodRooms") as? [String: TimeInterval]) ?? [:]
        self.momentsCreated = UserDefaults.standard.integer(forKey: "momentsCreated")
        self.moodRoomsCreated = UserDefaults.standard.integer(forKey: "moodRoomsCreated")
    }

    func startMoment() {
        momentStart = Date()
    }

    func endMoment() {
        guard let start = momentStart else { return }
        let delta = Date().timeIntervalSince(start)
        timeInMoments += delta
        UserDefaults.standard.set(timeInMoments, forKey: "timeInMoments")
        momentStart = nil
    }

    func startMoodRoom(background: String, schedule: String) {
        moodStart = Date()
        let recurring = schedule.lowercased().contains("every") || schedule.lowercased().contains("daily")
        currentMoodKey = "\(background)-" + (recurring ? "recurring" : "once")
    }

    func endMoodRoom() {
        guard let start = moodStart, let key = currentMoodKey else { return }
        let delta = Date().timeIntervalSince(start)
        var dict = timeInMoodRooms
        dict[key, default: 0] += delta
        timeInMoodRooms = dict
        UserDefaults.standard.set(dict, forKey: "timeInMoodRooms")
        moodStart = nil
        currentMoodKey = nil
    }

    func recordMomentCreated() {
        momentsCreated += 1
        UserDefaults.standard.set(momentsCreated, forKey: "momentsCreated")
    }

    func recordMoodRoomCreated() {
        moodRoomsCreated += 1
        UserDefaults.standard.set(moodRoomsCreated, forKey: "moodRoomsCreated")
    }
}
