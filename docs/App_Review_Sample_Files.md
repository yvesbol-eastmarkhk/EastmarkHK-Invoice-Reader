# App Review sample files

Apple App Review needs downloadable PEPPOL XML samples hosted at a permanent URL.

## Permanent sample URLs (live now)

These are on the public GitHub repository (HTTP 200 verified):

1. **Invoice without embedded PDF** (use this first):  
   https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/01_invoice_generated_pdf.xml

2. **Invoice with embedded PDF**:  
   https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/02_invoice_embedded_pdf.xml

3. **Credit note**:  
   https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/03_credit_note.xml

Folder: https://github.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/tree/main/samples

## Website mirrors (after FTP deploy of eastmarkhk.com)

- https://eastmarkhk.com/samples/peppol-invoice-reader/
- https://eastmarkhk.com/samples/peppol-invoice-reader/01_invoice_generated_pdf.xml
- https://eastmarkhk.com/samples/peppol-invoice-reader/02_invoice_embedded_pdf.xml
- https://eastmarkhk.com/samples/peppol-invoice-reader/03_credit_note.xml

Files are already committed in the `eastmarkhk.com` repo under `samples/peppol-invoice-reader/`. Upload that folder to the live server (PhpStorm Deployment / FTP) so the brand domain URLs work too.

## How reviewers should test

1. Download a sample XML.
2. In the app: **File → Open XML…** (⌘O) or the green **Open XML…** button.
3. Check Summary, Lines, XML, PDF preview, then **Save PDF…**.

## App Store Connect reply (copy-paste)

```
Hello,

Thank you for the feedback. Here are permanent sample PEPPOL / UBL XML files for App Review:

1) Invoice without embedded PDF (primary test file):
https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/01_invoice_generated_pdf.xml

2) Invoice with embedded PDF attachment:
https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/02_invoice_embedded_pdf.xml

3) Credit note:
https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/03_credit_note.xml

Index / folder:
https://github.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/tree/main/samples

How to test in the app:
• File → Open XML… (⌘O), or click the green Open XML… button
• Open the downloaded XML
• Review Summary, Lines, XML, and PDF tabs
• Optionally use Save PDF…

These URLs will remain available for future reviews.

Best regards,
Eastmark (Asia) Limited
```
