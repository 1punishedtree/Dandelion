import SwiftUI

struct OptionsView: View {
    @EnvironmentObject private var store: PasswordStore

    var body: some View {
        NavigationStack {
            Form {
                Section("预设") {
                    Picker("预设", selection: Binding(get: {
                        store.preset
                    }, set: { preset in
                        store.applyPreset(preset)
                    })) {
                        ForEach(PasswordPreset.allCases, id: \.self) { preset in
                            Text(preset.title)
                                .tag(preset)
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
                        Text("基础")
                            .tag(PasswordOptions.SymbolSet.basic)
                        Text("扩展")
                            .tag(PasswordOptions.SymbolSet.extended)
                    }
                    .disabled(!store.options.includeSymbols)
                }

                Section("密码长度") {
                    Stepper(value: $store.options.length, in: PasswordOptions.lengthRange) {
                        HStack {
                            Text("长度")
                            Spacer()
                            Text("\(store.options.length)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("密码数量") {
                    Stepper(value: $store.options.count, in: PasswordOptions.countRange) {
                        HStack {
                            Text("数量")
                            Spacer()
                            Text("\(store.options.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("剪贴板") {
                    Toggle("复制后自动清除", isOn: $store.options.autoClearClipboard)
                    Stepper(value: $store.options.clipboardClearDelaySeconds, in: 5...120, step: 5) {
                        HStack {
                            Text("清除延迟")
                            Spacer()
                            Text("\(store.options.clipboardClearDelaySeconds) 秒")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(!store.options.autoClearClipboard)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("选项")
        }
    }
}
