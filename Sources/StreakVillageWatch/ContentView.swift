import SwiftUI

struct ContentView: View {
    @AppStorage("sv_streak") private var streak: Int = 0
    @AppStorage("sv_total") private var total: Int = 0
    @AppStorage("sv_checked_today") private var checkedToday: Bool = false
    @AppStorage("sv_last_check_date") private var lastCheckDate: String = ""

    private var todayString: String {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("🏘️ Village")
                .font(.headline)
            Text("🔥 \(streak) day streak")
                .font(.title3)
                .foregroundStyle(.orange)
            Label("\(total) total", systemImage: "calendar")
                .font(.caption)
            Button {
                if lastCheckDate != todayString {
                    lastCheckDate = todayString
                    checkedToday = true
                    total += 1
                    streak += 1
                }
            } label: {
                Label(checkedToday && lastCheckDate == todayString ? "✓ Done!" : "Check In",
                      systemImage: checkedToday && lastCheckDate == todayString ? "checkmark.circle.fill" : "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(checkedToday && lastCheckDate == todayString ? .green : .blue)
            .font(.caption)
        }
        .padding()
    }
}

#Preview { ContentView() }
