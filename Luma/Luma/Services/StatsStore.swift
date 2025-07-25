import Foundation
import SwiftUI

@MainActor
class StatsStore: ObservableObject {
    @Published var timeInMoments: TimeInterval
    @Published var timeInMoodRooms: [String: TimeInterval]
    @Published var momentsCreated: Int
    @Published var moodRoomsCreated: Int
    @Published var dailyMoments: [String: TimeInterval]
    @Published var dailyMoodRooms: [String: TimeInterval]

    private var momentStart: Date?
    private var moodStart: Date?
    private var currentMoodKey: String?
    static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    init() {
        self.timeInMoments = UserDefaults.standard.double(forKey: "timeInMoments")
        self.timeInMoodRooms = (UserDefaults.standard.dictionary(forKey: "timeInMoodRooms") as? [String: TimeInterval]) ?? [:]
        self.momentsCreated = UserDefaults.standard.integer(forKey: "momentsCreated")
        self.moodRoomsCreated = UserDefaults.standard.integer(forKey: "moodRoomsCreated")
        self.dailyMoments = (UserDefaults.standard.dictionary(forKey: "dailyMoments") as? [String: TimeInterval]) ?? [:]
        self.dailyMoodRooms = (UserDefaults.standard.dictionary(forKey: "dailyMoodRooms") as? [String: TimeInterval]) ?? [:]
    }

    func startMoment() {
        momentStart = Date()
    }

    func endMoment() {
        guard let start = momentStart else { return }
        let delta = Date().timeIntervalSince(start)
        timeInMoments += delta
        UserDefaults.standard.set(timeInMoments, forKey: "timeInMoments")
        let key = Self.dayFormatter.string(from: start)
        var dict = dailyMoments
        dict[key, default: 0] += delta
        dailyMoments = dict
        UserDefaults.standard.set(dict, forKey: "dailyMoments")
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
        let dayKey = Self.dayFormatter.string(from: start)
        var moodDict = dailyMoodRooms
        moodDict[dayKey, default: 0] += delta
        dailyMoodRooms = moodDict
        UserDefaults.standard.set(moodDict, forKey: "dailyMoodRooms")
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

extension StatsStore {
    /// Returns a store populated with sample data for previews.
    static var sample: StatsStore {
        let store = StatsStore()

        store.timeInMoments = 60 * 45
        store.timeInMoodRooms = [
            "MoodRoomSad-recurring": TimeInterval(60 * 30),
            "MoodRoomNight-recurring": TimeInterval(60 * 60)
        ]

        store.momentsCreated = 5
        store.moodRoomsCreated = 3

        let today = Date()
        var moments: [String: TimeInterval] = [:]
        var moods: [String: TimeInterval] = [:]
        for offset in -6...0 {
            if let date = Calendar.current.date(byAdding: .day, value: offset, to: today) {
                let key = dayFormatter.string(from: date)
                moments[key] = Double.random(in: 300...1800)
                moods[key] = Double.random(in: 120...900)
            }
        }
        store.dailyMoments = moments
        store.dailyMoodRooms = moods

        return store
    }
}
