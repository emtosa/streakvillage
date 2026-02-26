import XCTest
import SwiftUI
@testable import StreakVillage

@MainActor
final class ScreenshotTests: XCTestCase {

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

    let sizes: [(CGFloat, CGFloat)] = [(1320, 2868), (1284, 2778), (2064, 2752)]

    func testGenerateScreenshots() throws {
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        for (w, h) in sizes {
            let label = "\(Int(w))x\(Int(h))"
            save(MenuShot(w: w, h: h),    name: "01-menu-\(label)")
            save(VillageShot(w: w, h: h), name: "02-village-\(label)")
            save(StatsShot(w: w, h: h),   name: "03-stats-\(label)")
            save(GridShot(w: w, h: h),    name: "04-grid-\(label)")
        }
    }

    private func save(_ view: some View, name: String) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1.0
        guard let uiImage = renderer.uiImage,
              let data = uiImage.jpegData(compressionQuality: 0.92) else { XCTFail("Render failed: \(name)"); return }
        let url = outputDir.appendingPathComponent("\(name).jpg")
        try? data.write(to: url)
        print("📸 \(url.lastPathComponent)")
    }
}

private let villageTiles = ["🏠","🏡","🏘️","🌳","🌲","🌿","🌾","🪵","⛺","🏗️"]

private struct MenuShot: View {
    let w, h: CGFloat
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.1,blue:0.06), Color(red:0.08,green:0.22,blue:0.1)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: h * 0.04) {
                Spacer()
                Text("🏘️").font(.system(size: h * 0.1))
                Text("Streak Village").font(.system(size: h * 0.046, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Text("Show up daily. Watch your village grow.").font(.system(size: h * 0.022, design: .rounded)).foregroundStyle(.white.opacity(0.6)).multilineTextAlignment(.center).padding(.horizontal, w*0.12)
                Spacer()
                Text("ENTER VILLAGE").font(.system(size: h * 0.025, weight: .heavy, design: .rounded))
                    .frame(width: w * 0.6, height: h * 0.07)
                    .background(Color.green).foregroundStyle(.white).clipShape(Capsule())
                Spacer()
            }
        }
    }
}

private struct VillageShot: View {
    let w, h: CGFloat
    let days = [0,1,2,3,5,6,7,8,10,11,12,14,15,16,17,19,20,21,22,24,25]
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.1,blue:0.06), Color(red:0.08,green:0.22,blue:0.1)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 0) {
                Text("🔥 Streak: 7 days").font(.system(size: h*0.03, weight:.heavy, design:.rounded)).foregroundStyle(.orange).padding(.top, h*0.06)
                Text("🧍🧍‍♀️ Your villagers cheer!").font(.system(size: h*0.022, design:.rounded)).foregroundStyle(.white.opacity(0.7)).padding(.vertical, h*0.01)
                Spacer()
                LazyVGrid(columns: Array(repeating: .init(.fixed(w*0.09)), count: 7), spacing: h*0.012) {
                    ForEach(0..<35) { i in
                        if days.contains(i) {
                            Text(villageTiles[i % villageTiles.count]).font(.system(size: w*0.07))
                        } else {
                            RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.06)).frame(width: w*0.09, height: w*0.09)
                        }
                    }
                }
                Spacer()
                Text("✅ Mark Today Done").font(.system(size: h*0.025, weight:.heavy, design:.rounded))
                    .frame(width: w*0.7, height: h*0.07)
                    .background(Color.green).foregroundStyle(.white).clipShape(Capsule())
                    .padding(.bottom, h*0.06)
            }
        }
    }
}

private struct StatsShot: View {
    let w, h: CGFloat
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.1,blue:0.06), Color(red:0.08,green:0.22,blue:0.1)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: h*0.03) {
                Spacer()
                Text("📊 Your Progress").font(.system(size: h*0.042, weight:.heavy, design:.rounded)).foregroundStyle(.white)
                ForEach([("🔥","Current Streak","7 days"),("🏆","Longest Streak","14 days"),("🏠","Total Buildings","21"),("📅","Total Days","25")], id:\.0) { (e,l,v) in
                    HStack {
                        Text(e).font(.system(size: h*0.04))
                        VStack(alignment:.leading) {
                            Text(l).font(.system(size: h*0.02, design:.rounded)).foregroundStyle(.white.opacity(0.55))
                            Text(v).font(.system(size: h*0.028, weight:.semibold, design:.rounded)).foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, w*0.12)
                }
                Spacer()
            }
        }
    }
}

private struct GridShot: View {
    let w, h: CGFloat
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.1,blue:0.06), Color(red:0.08,green:0.22,blue:0.1)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: h*0.025) {
                Spacer()
                Text("No missed day punishment.").font(.system(size: h*0.03, weight:.heavy, design:.rounded)).foregroundStyle(.white).multilineTextAlignment(.center)
                Text("Your village just… pauses.").font(.system(size: h*0.025, design:.rounded)).foregroundStyle(.white.opacity(0.7))
                Text("Then continues when you return. 🌿").font(.system(size: h*0.025, design:.rounded)).foregroundStyle(.white.opacity(0.7))
                Spacer()
                LazyVGrid(columns: Array(repeating: .init(.fixed(w*0.09)), count: 7), spacing: h*0.012) {
                    ForEach(villageTiles, id:\.self) { t in
                        Text(t).font(.system(size: w*0.07))
                    }
                }
                Text("10 building tiles • 3 villagers").font(.system(size: h*0.02, design:.rounded)).foregroundStyle(.white.opacity(0.5))
                Spacer()
            }
        }
    }
}
