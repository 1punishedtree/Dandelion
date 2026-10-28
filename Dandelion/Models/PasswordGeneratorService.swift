import Foundation

enum PasswordGeneratorService {
    private static let uppercase = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    private static let lowercase = Array("abcdefghijklmnopqrstuvwxyz")
    private static let numbers = Array("0123456789")
    private static let basicSymbols = Array("!@#$%^&*()-_=+[]{};:,.<>?/")
    private static let extendedSymbols = Array("!@#$%^&*()-_=+[]{};:,.<>?/~`|\\")

    private static let ambiguousCharacters: Set<Character> = [
        "0", "O",
        "1", "l", "I",
    ]

    static func generate(options: PasswordOptions) -> [String] {
        var rng = SystemRandomNumberGenerator()
        return generate(options: options, using: &rng)
    }

    static func generate<R: RandomNumberGenerator>(options: PasswordOptions, using rng: inout R) -> [String] {
        let symbols: [Character]
        switch options.symbolSet {
        case .basic:
            symbols = basicSymbols
        case .extended:
            symbols = extendedSymbols
        }

        var enabledCharsets: [[Character]] = [
            options.includeUppercase ? uppercase : [],
            options.includeLowercase ? lowercase : [],
            options.includeNumbers ? numbers : [],
            options.includeSymbols ? symbols : [],
        ].filter { !$0.isEmpty }

        if options.excludeAmbiguousCharacters {
            enabledCharsets = enabledCharsets
                .map { $0.filter { !ambiguousCharacters.contains($0) } }
                .filter { !$0.isEmpty }
        }

        let pool = enabledCharsets.flatMap { $0 }
        guard !pool.isEmpty else { return [] }

        return (0..<options.count).map { _ in
            generateSinglePassword(length: options.length, enabledCharsets: enabledCharsets, pool: pool, using: &rng)
        }
    }

    private static func generateSinglePassword<R: RandomNumberGenerator>(
        length: Int,
        enabledCharsets: [[Character]],
        pool: [Character],
        using rng: inout R
    ) -> String {
        guard length > 0 else { return "" }

        var characters: [Character] = []

        if length >= enabledCharsets.count {
            for charset in enabledCharsets {
                if let required = charset.randomElement(using: &rng) {
                    characters.append(required)
                }
            }
        }

        let remaining = max(0, length - characters.count)
        for _ in 0..<remaining {
            if let next = pool.randomElement(using: &rng) {
                characters.append(next)
            }
        }

        shuffleInPlace(&characters, using: &rng)
        return String(characters)
    }

    private static func shuffleInPlace<R: RandomNumberGenerator>(_ array: inout [Character], using rng: inout R) {
        guard array.count > 1 else { return }
        for index in stride(from: array.count - 1, through: 1, by: -1) {
            let swapIndex = Int.random(in: 0...index, using: &rng)
            if swapIndex != index {
                array.swapAt(index, swapIndex)
            }
        }
    }
}
