import Foundation

// MARK: - DayEntry

struct DayEntry: Identifiable, Codable {
    let id:          UUID
    let date:        Date
    let checkedIn:   Bool      // false = gap day (no punishment)
    let tilePlaced:  String    // building emoji

    init(date: Date, checkedIn: Bool) {
        id             = UUID()
        self.date      = date
        self.checkedIn = checkedIn
        tilePlaced     = checkedIn ? DayEntry.randomTile() : ""
    }

    private static func randomTile() -> String {
        tiles.randomElement()!
    }

    static let tiles = ["🏠", "🏡", "🏘️", "🌳", "🌲", "🌿", "🌾", "🪵", "⛺", "🏗️"]
}

// MARK: - Villager

struct Villager: Identifiable {
    let id:    UUID
    let emoji: String
    var reactionEmoji: String = ""
    var reactionText:  String = ""

    static let pool: [Villager] = [
        Villager(id: UUID(), emoji: "🧍"),
        Villager(id: UUID(), emoji: "🧍‍♀️"),
        Villager(id: UUID(), emoji: "🧍‍♂️")
    ]
}

// MARK: - VillageStore

@MainActor
final class VillageStore: ObservableObject {

    @Published private(set) var entries:        [DayEntry]  = []
    @Published private(set) var villagers:      [Villager]  = Villager.pool
    @Published private(set) var checkedInToday: Bool        = false
    @Published private(set) var currentStreak:  Int         = 0
    @Published private(set) var longestStreak:  Int         = 0
    @Published private(set) var showReaction:   Bool        = false

    private let defaults = UserDefaults.standard
    private var reactionTask: Task<Void, Never>?

    init() { load() }

    // MARK: - Check-in

    func checkInToday() {
        guard !checkedInToday else { return }

        let today = Calendar.current.startOfDay(for: Date())
        let entry = DayEntry(date: today, checkedIn: true)
        entries.append(entry)
        checkedInToday = true
        recalculateStreaks()
        triggerVillagerReaction()
        persist()
    }

    // MARK: - Computed

    var totalCheckIns: Int { entries.filter { $0.checkedIn }.count }

    var buildingCount: Int { totalCheckIns }

    // MARK: - Streaks

    private func recalculateStreaks() {
        var streak = 0
        let sortedDates = entries
            .filter { $0.checkedIn }
            .map { Calendar.current.startOfDay(for: $0.date) }
            .sorted(by: >)

        var expected = Calendar.current.startOfDay(for: Date())
        for date in sortedDates {
            if date == expected {
                streak += 1
                expected = Calendar.current.date(byAdding: .day, value: -1, to: expected)!
            } else {
                break
            }
        }
        currentStreak = streak
        longestStreak = max(longestStreak, streak)
        defaults.set(longestStreak, forKey: "sv_longestStreak")
    }

    // MARK: - Villager reactions

    private func triggerVillagerReaction() {
        let reactions: [(emoji: String, text: String)] = [
            ("🎉", "Welcome home!"),
            ("👏", "You showed up!"),
            ("🌟", "Another day, another build!"),
            ("🥳", "The village grows!"),
            ("🔥", currentStreak > 1 ? "\(currentStreak)-day streak!" : "Day 1 — you started!")
        ]
        let reaction = reactions.randomElement()!

        villagers = villagers.map { v in
            var copy = v
            copy.reactionEmoji = reaction.emoji
            copy.reactionText  = reaction.text
            return copy
        }
        showReaction = true

        reactionTask?.cancel()
        reactionTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            self.showReaction = false
            self.villagers = Villager.pool
        }
    }

    // MARK: - Persistence

    private func persist() {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: "sv_entries")
        }
    }

    private func load() {
        if let data = defaults.data(forKey: "sv_entries"),
           let saved = try? JSONDecoder().decode([DayEntry].self, from: data) {
            entries = saved
        }
        longestStreak = defaults.integer(forKey: "sv_longestStreak")

        let today = Calendar.current.startOfDay(for: Date())
        checkedInToday = entries.contains {
            $0.checkedIn && Calendar.current.isDate($0.date, inSameDayAs: today)
        }
        recalculateStreaks()
    }
}
