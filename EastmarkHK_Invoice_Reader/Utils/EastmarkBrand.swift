import Foundation

enum EastmarkBrand {
    static let companyName = "EastmarkHK"
    static let websiteURL = URL(string: "https://eastmarkhk.com/")!
    static let privacyPolicyURL = URL(string: "https://eastmarkhk.com/privacy/EastmarkHK_PEPPOL_Invoice_Reader_Privacy_Report.pdf")!
    static let privacyPageURL = URL(string: "https://eastmarkhk.com/privacy/")!
}

enum AppInfo {
    static var marketingVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}
