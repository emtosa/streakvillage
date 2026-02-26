# Streak Village

An ADHD habit-building game by [Foculoom](https://foculoom.com).

## Concept

Every day you check in, a building appears in your village. Miss a day? The village just pauses — no guilt, no punishment, no broken streaks. Show up again and it continues where you left off.

## How It Works

1. Open the app
2. Tap **Place today's building**
3. A random building tile appears in your village grid 🏠🌳⛺
4. Villagers react to your arrival 🎉

## Village Tiles

🏠 🏡 🏘️ 🌳 🌲 🌿 🌾 🪵 ⛺ 🏗️

Each check-in places one tile. Gap days leave an empty cell — visible but not punished.

## Stats

- 🔥 Current streak (consecutive days)
- 🏆 Longest streak ever
- 🏠 Total buildings placed

## Villagers

Three stick-figure villagers react every time you check in:

| Villager | Emoji |
|---------|-------|
| Villager 1 | 🧍 |
| Villager 2 | 🧍‍♀️ |
| Villager 3 | 🧍‍♂️ |

## Design Philosophy

No punishment mechanics. No "you broke your streak" message. This is for ADHD brains — shame spirals don't help. The village just grows when you show up.

## Tech

- Swift 6, SwiftUI
- iOS 17+ / iPadOS 17+
- 100% offline, no accounts, no ads

## Build

```bash
cd streakvillage
xcodegen generate
open StreakVillage.xcodeproj
```
