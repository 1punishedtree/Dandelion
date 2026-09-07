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
        NavigationStack {
            Group {
                if !store.options.hasValidCharset {
                    noCharsetState
                } else if store.passwords.isEmpty {
                    emptyState
                } else {
                    passwordList
                        .blur(radius: scenePhase == .active ? 0 : 12)
                        .overlay {
                            if scenePhase != .active {
                                VStack(spacing: 12) {
                                    Image(systemName: "eye.slash")
                                        .font(.largeTitle)
                                        .foregroundStyle(.secondary)
                                    Text("已隐藏密码内容")
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                }
            }
            .navigationTitle("密码")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.regenerate()
                        copiedPassword = nil
                    } label: {
                        Label("刷新", systemImage: "arrow.clockwise")
                    }
                    .disabled(!store.options.hasValidCharset)
                }
            }
        }
    }

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
                Button("复制") {
                    copy(password)
                }
                Button("重新生成") {
                    store.regenerate()
                }
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
        .onAppear {
            store.regenerate()
        }
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
                if copiedPassword == password {
                    copiedPassword = nil
                }
            }

            var shouldAutoClear = false
            var delaySeconds = 0
            await MainActor.run {
                shouldAutoClear = store.options.autoClearClipboard
                delaySeconds = store.options.clipboardClearDelaySeconds
            }

            guard shouldAutoClear else { return }
            let delay = max(1, delaySeconds)
            try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
            await MainActor.run {
                clearClipboardIfStillMatching(password)
            }
        }
    }

    private func clearClipboardIfStillMatching(_ password: String) {
        #if os(iOS)
        if UIPasteboard.general.string == password {
            UIPasteboard.general.items = []
        }
        #elseif os(macOS)
        if NSPasteboard.general.string(forType: .string) == password {
            NSPasteboard.general.clearContents()
        }
        #endif
    }
}
