# EastmarkHK Invoice Reader

Native macOS app (Swift + SwiftUI) for PEPPOL BIS Billing 3.0 UBL invoices.

## Behaviour

1. **PDF in XML** — If the PEPPOL file contains an embedded PDF
   (`cac:AdditionalDocumentReference` / `EmbeddedDocumentBinaryObject`), that
   document is shown as-is. No new invoice is generated.
2. **No PDF in XML** — An invoice PDF is generated from the structured data
   (supplier, lines, totals, QR payment), in the system language. **No EastmarkHK
   logo** is added — this is the customer's invoice, not ours.
3. **Tabs** — Summary, Lines, XML (full source), PDF preview.
4. **Language** — Follows the macOS system language. English is the source of
   truth. Common languages ship curated. Other languages use Apple Translation,
   then Mistral if a key is saved in Settings.

## Build

```bash
./scripts/build_dmg.sh
```

Requires Xcode 15+ and `create-dmg` (`brew install create-dmg`).

Output: `dist/EastmarkHK Invoice Reader.app` and `EastmarkHK Invoice Reader.dmg`

### Code signing & notarization (local)

Uses the same EastmarkHK credentials as e-Invoicing: team **GXA7QXQK2X**, notary profile **EastmarkHK**.

```bash
# Build + sign (Developer ID auto-detected from Keychain)
./scripts/build_dmg.sh

# Build + sign + notarize DMG in one step
NOTARIZE=1 ./scripts/build_dmg.sh

# Or notarize an existing build
./scripts/notarize.sh
```

Override if needed: `DEVELOPER_ID_SIGNING_IDENTITY`, `NOTARY_KEYCHAIN_PROFILE`, `DEVELOPMENT_TEAM`.

## GitHub & Xcode Cloud

Create the public GitHub repo (for Xcode Cloud):

```bash
chmod +x scripts/*.sh ci_scripts/*.sh
./scripts/setup_github.sh
```

Default repo name: `EastmarkHK-Invoice-Reader` (override with `GITHUB_REPO_NAME`).

### Xcode Cloud setup

1. Open `EastmarkHK Invoice Reader.xcodeproj` in Xcode (run `xcodegen generate` first).
2. **Product → Xcode Cloud → Create Workflow**.
3. Connect the GitHub repository created above.
4. Scheme: `EastmarkHK_Invoice_Reader`, platform: macOS.
5. `ci_scripts/ci_post_clone.sh` installs XcodeGen and generates the project.
6. **App Store Connect:** leave `PACKAGE_DMG` unset — `ci_post_xcodebuild.sh` exits cleanly and does not block upload.
7. **Direct-download DMG (optional):** use an **Archive** workflow and set `PACKAGE_DMG=1`. Optionally `NOTARIZE=1` and `NOTARY_KEYCHAIN_PROFILE=EastmarkHK`.

Privacy policy: [EastmarkHK PEPPOL Invoice Reader Privacy Report](https://eastmarkhk.com/privacy/EastmarkHK_PEPPOL_Invoice_Reader_Privacy_Report.pdf)

## Project layout

```
EastmarkHK Invoice Reader/          # repository root
EastmarkHK_Invoice_Reader/          # Swift sources (Xcode target)
├── L10n/            English catalog, Apple + Mistral translation, cache
├── Models/          PeppolInvoice
├── Parser/          UBL XML → model + embedded PDF extraction
├── PDF/             PDFBuilder (fallback only) + QRCodeGenerator
└── Views/           SwiftUI UI
assets/              App icon + DMG background
ci_scripts/          Xcode Cloud hooks
sample_invoice.xml   Test fixture (no embedded PDF)
```

## Development

```bash
xcodegen generate
open "EastmarkHK Invoice Reader.xcodeproj"
```
