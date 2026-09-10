# EastmarkHK Invoice Reader — Microsoft Store (Partner Center) metadata

Copy-paste text for a Windows Store listing, mirroring the App Store Connect
metadata. **Read the note at the bottom first — there is currently no
Windows build of this app.**

## Product Info

- **App name**: `EastmarkHK Invoice Reader`
- **Category**: Business
- **Subcategory**: Accounting & Finance
- **Pricing**: Free
- **Publisher display name**: `EastmarkHK`

## Short description / Store subtitle (~100 char, shown under the name)

```
Open PEPPOL / UBL e-invoices and preview or save them as PDF — fast, native, works offline.
```

## Description (Microsoft Store allows up to 10,000 characters — same copy as the Mac listing works as-is)

```
EastmarkHK Invoice Reader opens PEPPOL BIS Billing 3.0 / UBL electronic invoices and shows you exactly what's inside — clearly, natively, on your PC.

Built for finance and back-office teams who receive e-invoices through PEPPOL and need a fast way to check them without wrestling with raw XML.

WHAT YOU SEE
- Summary — supplier, customer, invoice number, dates and totals at a glance
- Line items — every invoiced line with quantity, unit price, VAT and line total
- Raw XML — the full source document, for when you need to double-check the data
- PDF preview — the invoice as a document you can view and save

THE RIGHT PDF, EVERY TIME
If the sender's invoice already includes a PDF, EastmarkHK Invoice Reader shows you that exact document — nothing re-generated, nothing re-interpreted. If it doesn't, the app builds a clean invoice PDF from the structured data, including a scannable SEPA/EPC QR payment code where bank details are present, ready to save, print or forward.

PRIVATE BY DESIGN
EastmarkHK Invoice Reader needs no account, no sign-in and no cloud sync. It reads only the invoice file you choose to open, and writes only the PDF you choose to save. Full details are in the in-app Privacy Policy.

Free to use, from EastmarkHK — makers of business tools for teams handling invoicing, trade and logistics.
```

(The Mac listing's "WORKS IN YOUR LANGUAGE" section is omitted here since the on-device Apple Translation / optional Mistral fallback is Swift/macOS-specific code — drop or rewrite that paragraph once you know what a Windows build actually supports.)

## Search terms (Partner Center: up to 7, 30 chars each)

```
peppol
ubl invoice
e-invoicing
xml invoice
vat invoice
business pdf
belgium invoice
```

## URLs

- **Support contact** (required — email or URL): `eastmarkhk@eastmarkhk.com` or `https://eastmarkhk.com/support`
- **Website** (optional): `https://eastmarkhk.com`
- **Privacy Policy URL** (required): same PDF as macOS once content is confirmed accurate for the Windows build: `https://eastmarkhk.com/privacy/EastmarkHK_PEPPOL_Invoice_Reader_Privacy_Report.pdf`

## Age rating (IARC questionnaire in Partner Center)

Answer "No" to every content category (violence, fear, sexual content, gambling, drugs, user-generated content, etc.) — result: rated for everyone (ESRB Everyone / PEGI 3).

## Store listing images

Microsoft Store requires at least one screenshot per listing, minimum **1366×768**, PNG or JPEG (unlike the Mac App Store's 1280×800 minimum) — same screenshots conceptually (Summary, Lines, PDF preview tabs), just re-captured on Windows at the right resolution.

---

## Important: there's no Windows build to submit yet

Two different codebases exist for this app, and neither is Windows-ready today:

1. **The current native app** (`EastmarkHK Invoice Reader.xcodeproj`, Swift + SwiftUI) is macOS-only — SwiftUI/AppKit code doesn't run on Windows at all. This would need a separate rewrite for Windows (e.g. WinUI 3, or a cross-platform framework), not a recompile.
2. **The original Python/PySide6 version** I built first (in `/home/claude/peppol_invoice_reader/` — parser, PDF builder, and UI) *is* cross-platform, since PySide6/Qt runs on Windows. It's never been run or packaged on Windows, though, and it's missing the newer Swift app's features (translation, QR payment codes on generated PDFs). It would need: a test pass on an actual Windows machine, a PyInstaller Windows build, and packaging as an **MSIX** package (Microsoft Store's required format — a plain `.exe` isn't accepted).

If you want to go this route, the realistic path is: take the Python version as the Windows starting point, port over the QR-code/EPC payment feature from the Swift app, then build and test it on a real Windows PC (I don't have one to test on — my access to your machine is a Mac-only bridge). Let me know if you'd like me to prep that Python version and a `build_msix.ps1`-style script for you to run there.
