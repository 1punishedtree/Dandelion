import Combine
import Foundation

final class PasswordStore: ObservableObject {
    @Published var options = PasswordOptions()
    @Published var passwords: [String] = []

    @Published private(set) var preset: PasswordPreset = .standard

    private var optionsCancellable: AnyCancellable?
    private var presetCancellable: AnyCancellable?

    init() {
        preset = PasswordPreset.detect(from: options)

        presetCancellable = $options
            .removeDuplicates()
            .sink { [weak self] options in
                self?.preset = PasswordPreset.detect(from: options)
            }

        optionsCancellable = $options
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.regenerate()
            }
    }

    func applyPreset(_ preset: PasswordPreset) {
        guard preset != .custom else { return }
        let autoClearClipboard = options.autoClearClipboard
        let clipboardClearDelaySeconds = options.clipboardClearDelaySeconds

        options = preset.options
        options.autoClearClipboard = autoClearClipboard
        options.clipboardClearDelaySeconds = clipboardClearDelaySeconds
    }

    func regenerate() {
        guard options.hasValidCharset else {
            passwords = []
            return
        }
        passwords = PasswordGeneratorService.generate(options: options)
    }
}
