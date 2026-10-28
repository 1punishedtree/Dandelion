import SwiftUI

@main
struct DandelionApp: App {
    @StateObject private var store = PasswordStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        .defaultSize(width: 1000, height: 700)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
