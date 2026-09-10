# EastmarkHK Invoice Reader — App Store Connect metadata

Copy-paste text for the App Store Connect listing (macOS app, free).

## App Information

- **Name** (30 char max): `EastmarkHK Invoice Reader`
- **Subtitle** (30 char max): `PEPPOL / UBL Invoice Reader`
- **Bundle ID**: `com.eastmarkhk.peppol-invoice-reader` (already set in project.yml — must be registered under this exact value in the Apple Developer portal → Certificates, IDs & Profiles → Identifiers)
- **SKU** (your own internal reference, not shown publicly): `eastmarkhk-invoice-reader-mac-001`
- **Primary category**: Business
- **Secondary category** (optional): Productivity
- **Price**: Free
- **Copyright**: `© 2026 EastmarkHK`

## Promotional text (170 char max — editable anytime without a new review)

```
See exactly what was sent: summary, line items, raw XML and a ready-to-save PDF for any PEPPOL e-invoice — fast, native, and works offline.
```

## Description (4000 char max)

```
EastmarkHK Invoice Reader opens PEPPOL BIS Billing 3.0 / UBL electronic invoices and shows you exactly what's inside — clearly, natively, on your Mac.

Built for finance and back-office teams who receive e-invoices through PEPPOL and need a fast way to check them without wrestling with raw XML.

WHAT YOU SEE
- Summary — supplier, customer, invoice number, dates and totals at a glance
- Line items — every invoiced line with quantity, unit price, VAT and line total
- Raw XML — the full source document, for when you need to double-check the data
- PDF preview — the invoice as a document you can view and save

THE RIGHT PDF, EVERY TIME
If the sender's invoice already includes a PDF, EastmarkHK Invoice Reader shows you that exact document — nothing re-generated, nothing re-interpreted. If it doesn't, the app builds a clean invoice PDF from the structured data, including a scannable SEPA/EPC QR payment code where bank details are present, ready to save, print or forward.

WORKS IN YOUR LANGUAGE
The interface follows your Mac's system language, using Apple's built-in on-device Translation where available. If you want extra languages beyond the built-in set, you can optionally add your own Mistral AI API key in Settings — translation requests are then sent to Mistral using that key. This is entirely optional and off by default.

PRIVATE BY DESIGN
EastmarkHK Invoice Reader needs no account, no sign-in and no cloud sync. It reads only the invoice file you choose to open, and writes only the PDF you choose to save. By default nothing leaves your Mac; the only exception is the optional Mistral translation described above, which you control. Full details are in the in-app Privacy Policy.

Free to use, from EastmarkHK — makers of business tools for teams handling invoicing, trade and logistics.
```

## Keywords (100 char max, comma-separated)

```
peppol,ubl,e-invoice,invoice,einvoicing,xml,billing,vat,pdf,business,accounting,belgium,europe
```

## URLs

- **Support URL**: `https://eastmarkhk.com/support`
- **Marketing URL** (optional): `https://eastmarkhk.com`
- **Privacy Policy URL** (required): `https://eastmarkhk.com/privacy/EastmarkHK_PEPPOL_Invoice_Reader_Privacy_Report.pdf`

## Age Rating questionnaire

Answer "None" / "No" to every category (violence, sexual content, gambling, horror, drugs, etc.) — this is a business utility with no such content. Result: **4+**.

## App Privacy questionnaire (App Store Connect → App Privacy)

Matches the in-app Privacy Policy:

- **Data collected**: None linked to identity, none used for tracking.
- **Data used to track you**: No.
- One nuance to declare accurately: if a user adds their own Mistral API key for extra-language translation, invoice **UI text strings** (not invoice financial data) are sent to Mistral's API using that key. Recommended answer: declare **no data collection by EastmarkHK**, since this is an optional, user-configured, user-controlled integration using the user's own third-party account — not data EastmarkHK collects. This mirrors how "Sign in with a third-party API key you provide" features are typically declared.

## What's New in This Version (first release)

```
Initial release.
```

---

## Before you submit — things this text doesn't cover

1. **Sandboxing.** The entitlements file currently only requests `com.apple.security.network.client`. A Mac App Store build must also have `com.apple.security.app-sandbox` enabled, plus file-access entitlements for the Open/Save panels (`com.apple.security.files.user-selected.read-write`). I can make this change in the project now if you'd like — say the word and I'll edit the `.entitlements` file and `project.yml`.
2. **Cross-app Mistral key import.** `MistralKeyStore.importFromEInvoicing()` reads the e-Invoicing app's Application Support folder directly. Under App Sandbox this will silently stop working (each app gets an isolated container) unless the two apps share an App Group entitlement. Not a blocker — it just quietly falls back to "no key found," which is fine — but worth knowing before you rely on it during testing.
3. **Privacy Policy PDF is now slightly out of date.** The one I generated for you says "no network connections whatsoever," written when this was the offline-only Python build. The current Swift app *can* call Mistral's API for translation once a user adds their own key. I'd recommend I update that PDF (Section 3 and the nutrition-label table) before you submit — happy to do that now.
4. **App Store Connect account steps I can't do for you**: registering the bundle ID, creating the app record, uploading screenshots, and submitting for review all happen on Apple's site under your Apple ID — I can't log in there on your behalf. I can prepare everything that goes *into* those screens.
5. **Screenshots.** App Store Connect needs at least one 1280×800 (or larger) macOS screenshot. I don't have a way to see your screen, so you'd need to run the app and capture a few tab views yourself (Summary, Lines, PDF preview look best) — I can tell you exactly which `cmd+shift+4`-style shots to take if useful.
