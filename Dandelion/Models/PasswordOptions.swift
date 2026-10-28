import Foundation

struct PasswordOptions: Equatable {
    enum SymbolSet: String, CaseIterable, Identifiable {
        case basic
        case extended

        var id: String { rawValue }
    }

    var includeUppercase: Bool = true
    var includeLowercase: Bool = true
    var includeNumbers: Bool = true
    var includeSymbols: Bool = false
    var length: Int = 32
    var count: Int = 2

    var excludeAmbiguousCharacters: Bool = false
    var symbolSet: SymbolSet = .basic

    var autoClearClipboard: Bool = true
    var clipboardClearDelaySeconds: Int = 30

    static let lengthRange = 4...64
    static let countRange = 1...50

    var hasValidCharset: Bool {
        includeUppercase || includeLowercase || includeNumbers || includeSymbols
    }

    var enabledCharsetCount: Int {
        var count = 0
        if includeUppercase { count += 1 }
        if includeLowercase { count += 1 }
        if includeNumbers { count += 1 }
        if includeSymbols { count += 1 }
        return count
    }
}

enum PasswordPreset: String, CaseIterable, Identifiable {
    case standard
    case readable
    case strong
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard:
            "标准"
        case .readable:
            "可读"
        case .strong:
            "强密码"
        case .custom:
            "自定义"
        }
    }

    static func detect(from options: PasswordOptions) -> PasswordPreset {
        if options == PasswordPreset.standard.options {
            return .standard
        }
        if options == PasswordPreset.readable.options {
            return .readable
        }
        if options == PasswordPreset.strong.options {
            return .strong
        }
        return .custom
    }

    var options: PasswordOptions {
        switch self {
        case .standard:
            PasswordOptions(
                includeUppercase: true,
                includeLowercase: true,
                includeNumbers: true,
                includeSymbols: false,
                length: 32,
                count: 2,
                excludeAmbiguousCharacters: false,
                symbolSet: .basic,
                autoClearClipboard: true,
                clipboardClearDelaySeconds: 30
            )
        case .readable:
            PasswordOptions(
                includeUppercase: true,
                includeLowercase: true,
                includeNumbers: true,
                includeSymbols: false,
                length: 16,
                count: 5,
                excludeAmbiguousCharacters: true,
                symbolSet: .basic,
                autoClearClipboard: true,
                clipboardClearDelaySeconds: 30
            )
        case .strong:
            PasswordOptions(
                includeUppercase: true,
                includeLowercase: true,
                includeNumbers: true,
                includeSymbols: true,
                length: 24,
                count: 5,
                excludeAmbiguousCharacters: false,
                symbolSet: .extended,
                autoClearClipboard: true,
                clipboardClearDelaySeconds: 30
            )
        case .custom:
            PasswordOptions()
        }
    }
}
