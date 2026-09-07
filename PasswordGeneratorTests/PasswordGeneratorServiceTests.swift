import XCTest

@testable import PasswordGenerator

final class PasswordGeneratorServiceTests: XCTestCase {
    func testGenerateReturnsEmptyWhenNoCharsets() {
        let options = PasswordOptions(
            includeUppercase: false,
            includeLowercase: false,
            includeNumbers: false,
            includeSymbols: false,
            length: 12,
            count: 5,
            excludeAmbiguousCharacters: false,
            symbolSet: .basic,
            autoClearClipboard: false,
            clipboardClearDelaySeconds: 30
        )

        var rng = SeededGenerator(seed: 1)
        let passwords = PasswordGeneratorService.generate(options: options, using: &rng)
        XCTAssertTrue(passwords.isEmpty)
    }

    func testGenerateRespectsLengthAndCount() {
        let options = PasswordOptions(
            includeUppercase: true,
            includeLowercase: true,
            includeNumbers: true,
            includeSymbols: true,
            length: 24,
            count: 10,
            excludeAmbiguousCharacters: false,
            symbolSet: .basic,
            autoClearClipboard: false,
            clipboardClearDelaySeconds: 30
        )

        var rng = SeededGenerator(seed: 42)
        let passwords = PasswordGeneratorService.generate(options: options, using: &rng)
        XCTAssertEqual(passwords.count, 10)
        XCTAssertTrue(passwords.allSatisfy { $0.count == 24 })
    }

    func testGenerateIncludesEachEnabledCharsetWhenLengthAllows() {
        let options = PasswordOptions(
            includeUppercase: true,
            includeLowercase: false,
            includeNumbers: true,
            includeSymbols: true,
            length: 12,
            count: 1,
            excludeAmbiguousCharacters: false,
            symbolSet: .basic,
            autoClearClipboard: false,
            clipboardClearDelaySeconds: 30
        )

        var rng = SeededGenerator(seed: 123)
        let passwords = PasswordGeneratorService.generate(options: options, using: &rng)
        XCTAssertEqual(passwords.count, 1)

        let password = passwords[0]
        XCTAssertEqual(password.count, 12)

        let symbolSet = Set("!@#$%^&*()-_=+[]{};:,.<>?/")
        XCTAssertTrue(password.contains(where: { $0.isUppercase }))
        XCTAssertTrue(password.contains(where: { $0.isNumber }))
        XCTAssertTrue(password.contains(where: { symbolSet.contains($0) }))
    }

    func testGenerateExcludesAmbiguousCharactersWhenEnabled() {
        let options = PasswordOptions(
            includeUppercase: true,
            includeLowercase: true,
            includeNumbers: true,
            includeSymbols: false,
            length: 32,
            count: 3,
            excludeAmbiguousCharacters: true,
            symbolSet: .basic,
            autoClearClipboard: false,
            clipboardClearDelaySeconds: 30
        )

        let ambiguous: Set<Character> = [
            "0", "O",
            "1", "l", "I",
        ]

        var rng = SeededGenerator(seed: 999)
        let passwords = PasswordGeneratorService.generate(options: options, using: &rng)
        XCTAssertEqual(passwords.count, 3)
        XCTAssertTrue(passwords.allSatisfy { password in
            !password.contains(where: { ambiguous.contains($0) })
        })
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}
