import XCTest
import SwiftUI
@testable import StreakVillage

// Generates Apple Watch App Store screenshots.
// Run: xcodebuild test -scheme StreakVillage -only-testing:StreakVillageTests/WatchScreenshotTests

@MainActor
final class WatchScreenshotTests: XCTestCase {

    let outputDir: URL = {
        if let dir = ProcessInfo.processInfo.environment["SCREENSHOTS_DIR"] {
            return URL(fileURLWithPath: dir)
        }
        return URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("AppStore/screenshots/en-US")
    }()

    // All required Watch sizes (width × height in pixels)
    let watchSizes: [(CGFloat, CGFloat)] = [
        (312, 390),  // Series 3
        (368, 448),  // Series 4 / Series 6
        (396, 484),  // Series 7 / Series 9
        (416, 496),  // Series 10 / Series 11
        (410, 502),  // Ultra
        (422, 514),  // Ultra 3
    ]

    func testGenerateWatchScreenshots() throws {
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        for (w, h) in watchSizes {
            let label = "\(Int(w))x\(Int(h))"
            save(w: w, h: h, WSVHome(w: w, h: h), name: "watch-01-home-\(label)")
            save(w: w, h: h, WSVStreak(w: w, h: h), name: "watch-02-detail-\(label)")
        }
    }

    private func save(w: CGFloat, h: CGFloat, _ view: some View, name: String) {
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(width: w, height: h)
        renderer.scale = 1.0
        guard let uiImage = renderer.uiImage,
              let data = uiImage.jpegData(compressionQuality: 0.92) else {
            XCTFail("Watch render failed: \(name)"); return
        }
        let url = outputDir.appendingPathComponent("\(name).jpg")
        try? data.write(to: url)
        print("⌚ \(url.lastPathComponent)")
    }
}

private struct WSVHome: View {
    let w, h: CGFloat
    var body: some View {
        ZStack {
            Color(red:0.04,green:0.1,blue:0.06)
            VStack(spacing: h*0.05) {
                Text("🏘️").font(.system(size: h*0.2))
                Text("Streak\nVillage")
                    .font(.system(size: h*0.09, weight:.heavy, design:.rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)
                Text("Daily builder").font(.system(size: h*0.065, design:.rounded)).foregroundStyle(.white.opacity(0.5))
            }.padding(w*0.06)
        }.frame(width: w, height: h)
    }
}

private struct WSVStreak: View {
    let w, h: CGFloat
    let tiles = ["🏠","🌳","🏡","🌲","🌿","⛺"]
    var body: some View {
        ZStack {
            Color(red:0.04,green:0.1,blue:0.06)
            VStack(spacing: h*0.04) {
                Text("🔥 7 days").font(.system(size: h*0.09, weight:.heavy, design:.rounded)).foregroundStyle(.orange)
                LazyVGrid(columns: Array(repeating:.init(.fixed(w*0.2)), count:3), spacing: h*0.02) {
                    ForEach(tiles, id:\.self) { t in Text(t).font(.system(size: h*0.1)) }
                }
                Text("Keep going!").font(.system(size: h*0.07, design:.rounded)).foregroundStyle(.white.opacity(0.7))
            }.padding(w*0.05)
        }.frame(width: w, height: h)
    }
}
