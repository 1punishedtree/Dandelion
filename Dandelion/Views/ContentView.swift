import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(macOS)
        HStack(spacing: 0) {
            OptionsView()
                .frame(width: 300)

            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(width: 1)

            PasswordListView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 1000, height: 700)
        #else
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
        #endif
    }
}
