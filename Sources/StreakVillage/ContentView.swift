import SwiftUI

struct ContentView: View {
    @StateObject private var store = VillageStore()

    var body: some View {
        VillageView()
            .environmentObject(store)
    }
}
