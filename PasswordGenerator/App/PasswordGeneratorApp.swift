import SwiftUI

@main
struct PasswordGeneratorApp: App {
    @StateObject private var store = PasswordStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        #endif
    }
}
