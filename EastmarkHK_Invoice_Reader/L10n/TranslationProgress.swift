import Foundation

struct TranslationProgress: Equatable {
    var languageName: String
    var engineKey: String
    var done: Int
    var total: Int

    var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(done) / Double(total)
    }
}
