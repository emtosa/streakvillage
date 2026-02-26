import SwiftUI

struct VillageView: View {
    @EnvironmentObject private var store: VillageStore

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        ZStack {
            background

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerBar
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    Spacer().frame(height: 24)

                    // Streak stats
                    streakStats
                        .padding(.horizontal, 20)

                    Spacer().frame(height: 28)

                    // Villagers + reactions
                    villagersRow
                        .padding(.horizontal, 20)

                    Spacer().frame(height: 28)

                    // Village grid
                    villageGrid
                        .padding(.horizontal, 16)

                    Spacer().frame(height: 32)

                    // Check-in button
                    checkInButton
                        .padding(.horizontal, 28)
                        .padding(.bottom, 48)
                }
            }
        }
    }

    // MARK: - Sub-views

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.08, blue: 0.14), Color(red: 0.02, green: 0.04, blue: 0.08)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("🏘️ Streak Village")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Show up. Build your world.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
        }
    }

    private var streakStats: some View {
        HStack(spacing: 0) {
            statCell(value: store.currentStreak,  label: "Current Streak", emoji: "🔥")
            Divider().background(.white.opacity(0.15)).frame(height: 40)
            statCell(value: store.longestStreak,  label: "Best Streak",    emoji: "🏆")
            Divider().background(.white.opacity(0.15)).frame(height: 40)
            statCell(value: store.buildingCount,  label: "Buildings",      emoji: "🏠")
        }
        .padding(.vertical, 14)
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statCell(value: Int, label: String, emoji: String) -> some View {
        VStack(spacing: 3) {
            Text(emoji).font(.system(size: 18))
            Text("\(value)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var villagersRow: some View {
        HStack(spacing: 16) {
            ForEach(store.villagers) { v in
                VStack(spacing: 4) {
                    ZStack {
                        Text(v.emoji).font(.system(size: 32))
                        if store.showReaction && !v.reactionEmoji.isEmpty {
                            Text(v.reactionEmoji)
                                .font(.system(size: 18))
                                .offset(x: 14, y: -18)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    if store.showReaction && !v.reactionText.isEmpty {
                        Text(v.reactionText)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.yellow)
                            .transition(.opacity)
                    }
                }
                .animation(.spring(response: 0.35), value: store.showReaction)
            }
            Spacer()
        }
    }

    private var villageGrid: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your Village")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.leading, 4)

            LazyVGrid(columns: columns, spacing: 8) {
                // Show last 63 days (9 weeks)
                ForEach(gridEntries(), id: \.self) { tile in
                    Text(tile)
                        .font(.system(size: tile.isEmpty ? 10 : 22))
                        .frame(width: 40, height: 40)
                        .background(tile.isEmpty ? Color.white.opacity(0.04) : Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private func gridEntries() -> [String] {
        let calendar  = Calendar.current
        let today     = calendar.startOfDay(for: Date())

        // Build a date → emoji dict (last check-in wins for any duplicate)
        var lookup: [Date: String] = [:]
        for entry in store.entries where entry.checkedIn {
            let key = calendar.startOfDay(for: entry.date)
            lookup[key] = entry.tilePlaced
        }

        // Last 63 days oldest → newest
        var result: [String] = []
        for offset in stride(from: -62, through: 0, by: 1) {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            result.append(lookup[date] ?? "")
        }
        return result
    }

    private var checkInButton: some View {
        Button {
            withAnimation(.spring(response: 0.4)) {
                store.checkInToday()
            }
        } label: {
            Label(
                store.checkedInToday ? "✓ Checked in today" : "Place today's building",
                systemImage: store.checkedInToday ? "checkmark.circle.fill" : "plus.square.fill"
            )
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(store.checkedInToday ? Color.green.opacity(0.4) : Color.green)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .shadow(color: store.checkedInToday ? .clear : .green.opacity(0.5), radius: 14, y: 6)
        }
        .disabled(store.checkedInToday)
    }
}
