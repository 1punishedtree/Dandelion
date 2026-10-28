import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct PasswordListView: View {
    @EnvironmentObject private var store: PasswordStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var copiedPassword: String?
    @State private var clearClipboardTask: Task<Void, Never>?

    var body: some View {
        #if os(macOS)
        macPasswordView
        #else
        NavigationStack {
            Group {
                if !store.options.hasValidCharset {
                    noCharsetState
                } else if store.passwords.isEmpty {
                    emptyState
                } else {
                    passwordList
                        .blur(radius: scenePhase == .active ? 0 : 12)
                }
            }
            .navigationTitle("密码")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        regenerate()
                    } label: {
                        Label("刷新", systemImage: "arrow.clockwise")
                    }
                    .disabled(!store.options.hasValidCharset)
                }
            }
        }
        #endif
    }

    #if os(macOS)
    private var macPasswordView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Spacer()
                Button {
                    sharePasswords()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)
                .help("复制全部密码")
                Button {
                    regenerate()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)
                .help("重新生成")
                .padding(.leading, 18)
            }
            .padding(.top, 24)

            Text("密码")
                .font(.system(size: 30, weight: .bold))
                .padding(.top, 12)
                .padding(.bottom, 10)

            Rectangle()
                .fill(Color.green)
                .frame(height: 2)

            if !store.options.hasValidCharset {
                noCharsetState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(store.passwords, id: \.self) { password in
                            Button {
                                copy(password)
                            } label: {
                                HStack {
                                    coloredPassword(password)
                                        .font(.system(size: 15, design: .monospaced))
                                        .lineLimit(1)
                                        .textSelection(.enabled)
                                    Spacer(minLength: 8)
                                    if copiedPassword == password {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                }
                                .padding(.vertical, 14)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                    .padding(.top, 4)
                }
                .blur(radius: scenePhase == .active ? 0 : 12)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .background(Color.white)
        .onAppear {
            if store.passwords.isEmpty { store.regenerate() }
        }
    }

    private func coloredPassword(_ password: String) -> some View {
        let pieces = password.map { character -> Text in
            let color: Color
            if character.isNumber {
                color = .blue
            } else if character.isUppercase {
                color = .primary
            } else if "!@#$%^&*()-_=+[]{};:,.<>?/\\|~`".contains(character) {
                color = .red
            } else {
                color = .secondary
            }
            return Text(String(character)).foregroundColor(color)
        }
        return pieces.reduce(Text("")) { $0 + $1 }
    }

    private func sharePasswords() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(store.passwords.joined(separator: "\n"), forType: .string)
        #endif
    }
    #endif

    private var passwordList: some View {
        List(store.passwords, id: \.self) { password in
            Button {
                copy(password)
            } label: {
                HStack {
                    Text(password)
                        .font(.system(.body, design: .monospaced))
                        .privacySensitive()
                    Spacer()
                    if copiedPassword == password {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("复制密码")
            .accessibilityHint("将密码复制到剪贴板")
            .contextMenu {
                Button("复制") { copy(password) }
                Button("重新生成") { regenerate() }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("点击右上角刷新按钮生成密码")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { store.regenerate() }
    }

    private var noCharsetState: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("请至少选择一种字符类型")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func regenerate() {
        store.regenerate()
        copiedPassword = nil
    }

    private func copy(_ password: String) {
        clearClipboardTask?.cancel()

        #if os(iOS)
        UIPasteboard.general.string = password
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(password, forType: .string)
        #endif

        copiedPassword = password
        clearClipboardTask = Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await MainActor.run {
                if copiedPassword == password { copiedPassword = nil }
            }
            var shouldAutoClear = false
            var delaySeconds = 0
            await MainActor.run {
                shouldAutoClear = store.options.autoClearClipboard
                delaySeconds = store.options.clipboardClearDelaySeconds
            }
            guard shouldAutoClear else { return }
            try? await Task.sleep(nanoseconds: UInt64(max(1, delaySeconds)) * 1_000_000_000)
            await MainActor.run { clearClipboardIfStillMatching(password) }
        }
    }

    private func clearClipboardIfStillMatching(_ password: String) {
        #if os(iOS)
        if UIPasteboard.general.string == password { UIPasteboard.general.items = [] }
        #elseif os(macOS)
        if NSPasteboard.general.string(forType: .string) == password { NSPasteboard.general.clearContents() }
        #endif
    }
}
