import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct OptionsView: View {
    @EnvironmentObject private var store: PasswordStore
    @State private var isAboutPresented = false

    var body: some View {
        #if os(macOS)
        VStack(alignment: .leading, spacing: 14) {
            VStack(spacing: 0) {
                    characterToggle("大写字母", isOn: $store.options.includeUppercase)
                    Divider().padding(.leading, 16)
                    characterToggle("小写字母", isOn: $store.options.includeLowercase)
                    Divider().padding(.leading, 16)
                    characterToggle("数字", isOn: $store.options.includeNumbers)
                    Divider().padding(.leading, 16)
                    characterToggle("特殊字符", isOn: $store.options.includeSymbols)
                }
            .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 10) {
                Text("密码长度")
                    .font(.headline)
                stepperRow(range: "4–64", value: $store.options.length, bounds: PasswordOptions.lengthRange)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("密码数量")
                    .font(.headline)
                stepperRow(range: "1–50", value: $store.options.count, bounds: PasswordOptions.countRange)
            }

            Spacer(minLength: 4)

            Button {
                isAboutPresented = true
            } label: {
                Label("关于", systemImage: "info.circle")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.92))
        .sheet(isPresented: $isAboutPresented) {
            aboutView
                .frame(width: 360, height: 220)
        }
        #else
        NavigationStack {
            Form {
                Section("预设") {
                    Picker("预设", selection: Binding(get: {
                        store.preset
                    }, set: { store.applyPreset($0) })) {
                        ForEach(PasswordPreset.allCases, id: \.self) { preset in
                            Text(preset.title).tag(preset)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("密码策略") {
                    Toggle("大写字母 (A-Z)", isOn: $store.options.includeUppercase)
                    Toggle("小写字母 (a-z)", isOn: $store.options.includeLowercase)
                    Toggle("数字 (0-9)", isOn: $store.options.includeNumbers)
                    Toggle("特殊符号 (!@#...)", isOn: $store.options.includeSymbols)
                    Toggle("排除易混淆字符 (O/0/I/l)", isOn: $store.options.excludeAmbiguousCharacters)
                    Picker("符号集合", selection: $store.options.symbolSet) {
                        Text("基础").tag(PasswordOptions.SymbolSet.basic)
                        Text("扩展").tag(PasswordOptions.SymbolSet.extended)
                    }
                    .disabled(!store.options.includeSymbols)
                }
                Section("密码长度") {
                    Stepper(value: $store.options.length, in: PasswordOptions.lengthRange) {
                        LabeledContent("长度", value: "\(store.options.length)")
                    }
                }
                Section("密码数量") {
                    Stepper(value: $store.options.count, in: PasswordOptions.countRange) {
                        LabeledContent("数量", value: "\(store.options.count)")
                    }
                }
                Section("剪贴板") {
                    Toggle("复制后自动清除", isOn: $store.options.autoClearClipboard)
                    Stepper(value: $store.options.clipboardClearDelaySeconds, in: 5...120, step: 5) {
                        LabeledContent("清除延迟", value: "\(store.options.clipboardClearDelaySeconds) 秒")
                    }
                    .disabled(!store.options.autoClearClipboard)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("选项")
        }
        #endif
    }

    private var aboutView: some View {
        VStack(spacing: 14) {
            Text("关于软件")
                .font(.title2.bold())
            Text("作者")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Link(destination: URL(string: "https://github.com/1punishedtree")!) {
                VStack(spacing: 6) {
                    Text("一颗被罚站的树")
                    Text("1punishedtree")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Label("GitHub", systemImage: "arrow.up.right.square")
                        .font(.callout)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    #if os(macOS)
    private func characterToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .toggleStyle(.switch)
            .tint(.green)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
    }

    private func stepperRow(range: String, value: Binding<Int>, bounds: ClosedRange<Int>) -> some View {
        HStack {
            Text(range)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(value.wrappedValue)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
            Stepper("", value: value, in: bounds)
                .labelsHidden()
                .fixedSize()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 11))
    }
    #endif
}
