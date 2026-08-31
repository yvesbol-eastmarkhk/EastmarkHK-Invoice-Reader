import AppKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var l10n: L10n
    @State private var apiKey = ""
    @State private var reveal = false
    @State private var mistralStatus = ""
    @State private var isError = false
    @State private var selectedLanguageKey = LocalePreferences.load()

    var body: some View {
        Form {
            Section(l10n.t("settingsLanguage")) {
                Picker(l10n.t("settingsLanguage"), selection: $selectedLanguageKey) {
                    ForEach(AppLanguages.all) { option in
                        Text(AppLanguages.labeledTitle(for: option, systemLabel: l10n.t("settingsLanguageSystem")))
                            .tag(option.storageKey)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedLanguageKey) { _, newValue in
                    Task { await l10n.setLanguage(storageKey: newValue) }
                }
            }

            Section(l10n.t("settingsPublisherSection")) {
                Button {
                    NSWorkspace.shared.open(EastmarkBrand.privacyPolicyURL)
                } label: {
                    Label(l10n.t("settingsPrivacyPolicy"), systemImage: "hand.raised")
                }
            }

            Section(l10n.t("settingsAboutSection")) {
                LabeledContent(l10n.t("settingsVersion"), value: AppInfo.marketingVersion)
                LabeledContent(l10n.t("settingsBuild"), value: AppInfo.buildNumber)
            }

            Section(l10n.t("settingsAiSection")) {
                Text(l10n.t("settingsAiHelp"))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    if reveal {
                        TextField(l10n.t("settingsMistralKeyPlaceholder"), text: $apiKey)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    } else {
                        SecureField(l10n.t("settingsMistralKeyPlaceholder"), text: $apiKey)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    }
                    Button {
                        reveal.toggle()
                    } label: {
                        Image(systemName: reveal ? "eye.slash" : "eye")
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(AppButtonStyle(variant: .subtle))
                    .help(l10n.t("settingsMistralKey"))
                }

                HStack(spacing: 10) {
                    AppActionButton(
                        title: l10n.t("settingsMistralOpenConsole"),
                        icon: "link",
                        variant: .secondary
                    ) {
                        NSWorkspace.shared.open(MistralKeyStore.consoleURL)
                    }
                    Spacer()
                    AppActionButton(
                        title: l10n.t("settingsMistralClear"),
                        icon: "trash",
                        variant: .destructive
                    ) {
                        MistralKeyStore.delete()
                        apiKey = ""
                        mistralStatus = l10n.t("settingsMistralMissing")
                        isError = false
                    }
                    AppActionButton(
                        title: l10n.t("settingsMistralSave"),
                        icon: "checkmark.circle.fill",
                        variant: .primary
                    ) {
                        saveMistralKey()
                    }
                    .keyboardShortcut(.defaultAction)
                }

                if !mistralStatus.isEmpty {
                    Text(mistralStatus)
                        .foregroundStyle(isError ? .red : .secondary)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(l10n.t("settingsTitle"))
        .frame(width: 520, height: 520)
        .onAppear {
            apiKey = MistralKeyStore.load()
            selectedLanguageKey = l10n.languageStorageKey
            mistralStatus = apiKey.isEmpty ? l10n.t("settingsMistralMissing") : l10n.t("settingsMistralSaved")
        }
        .onChange(of: l10n.languageStorageKey) { _, newValue in
            selectedLanguageKey = newValue
        }
    }

    private func saveMistralKey() {
        do {
            try MistralKeyStore.save(apiKey)
            apiKey = MistralKeyStore.load()
            mistralStatus = apiKey.isEmpty ? l10n.t("settingsMistralMissing") : l10n.t("settingsMistralSaved")
            isError = false
        } catch {
            mistralStatus = l10n.t("settingsMistralInvalid")
            isError = true
        }
    }
}
