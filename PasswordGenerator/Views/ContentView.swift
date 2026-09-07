import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            OptionsView()
                .tabItem {
                    Label("选项", systemImage: "slider.horizontal.3")
                }

            PasswordListView()
                .tabItem {
                    Label("密码", systemImage: "key.fill")
                }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 480)
        #endif
    }
}
