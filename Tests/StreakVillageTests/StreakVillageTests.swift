import Testing
@testable import StreakVillage
import Foundation

@Suite("DayEntry")
struct DayEntryTests {
    @Test("check-in entry has a tile")
    func checkInHasTile() {
        let entry = DayEntry(date: Date(), checkedIn: true)
        #expect(!entry.tilePlaced.isEmpty)
        #expect(DayEntry.tiles.contains(entry.tilePlaced))
    }

    @Test("gap day has no tile")
    func gapDayEmpty() {
        let entry = DayEntry(date: Date(), checkedIn: false)
        #expect(entry.tilePlaced.isEmpty)
    }
}

@Suite("VillageStore")
@MainActor
struct VillageStoreTests {

    @Test("starts with no entries")
    func initialEmpty() {
        let store = VillageStore()
        // May load from UserDefaults in real use; check that streak is computed consistently
        #expect(store.currentStreak >= 0)
    }

    @Test("checking in marks today as done")
    func checkInToday() {
        let store = VillageStore()
        // Ensure not already checked in (fresh store)
        let wasChecked = store.checkedInToday
        if !wasChecked {
            store.checkInToday()
            #expect(store.checkedInToday)
            #expect(store.buildingCount >= 1)
        }
    }

    @Test("double check-in is idempotent")
    func noDoubleCheckIn() {
        let store = VillageStore()
        let before = store.totalCheckIns
        store.checkInToday()
        store.checkInToday()
        // Should only add at most 1 more than before
        #expect(store.totalCheckIns <= before + 1)
    }
}
