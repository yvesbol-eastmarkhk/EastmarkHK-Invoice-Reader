# App Review sample files

Apple App Review needs downloadable PEPPOL XML samples hosted at a permanent URL.

## Easiest download (recommended)

ZIP of all three samples:  
https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/EastmarkHK_Invoice_Reader_App_Review_Samples.zip

Unzip, then in the app use **File → Open XML…** and pick one of the `.xml` files.

## Individual sample URLs (must be Raw / direct .xml)

> Important: use these **raw** links. Do **not** open/save the GitHub webpage (that HTML causes `crossorigin` XML errors).

1. **Invoice without embedded PDF** (primary):  
   https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/01_invoice_generated_pdf.xml

2. **Invoice with embedded PDF**:  
   https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/02_invoice_embedded_pdf.xml

3. **Credit note**:  
   https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/03_credit_note.xml

Folder: https://github.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/tree/main/samples

## How reviewers should test

1. Download the ZIP (or a raw `.xml` file) — not a GitHub HTML page.
2. In the app: **File → Open XML…** (⌘O) or the green **Open XML…** button.
3. Check Summary, Lines, XML, PDF preview, then **Save PDF…**.

## App Store Connect reply (copy-paste)

```
Hello,

Thank you for the feedback. Here are permanent sample PEPPOL / UBL XML files for App Review.

Easiest: download this ZIP, unzip it, then open any .xml file with File → Open XML… (⌘O):
https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/EastmarkHK_Invoice_Reader_App_Review_Samples.zip

Or download individual raw XML files (use these direct links, not the GitHub web page):

1) Invoice without embedded PDF (primary):
https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/01_invoice_generated_pdf.xml

2) Invoice with embedded PDF attachment:
https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/02_invoice_embedded_pdf.xml

3) Credit note:
https://raw.githubusercontent.com/yvesbol-eastmarkhk/EastmarkHK-Invoice-Reader/main/samples/03_credit_note.xml

How to test:
• File → Open XML… (⌘O), or click the green Open XML… button
• Open a downloaded .xml file from the ZIP
• Review Summary, Lines, XML, and PDF tabs
• Optionally use Save PDF…

These URLs will remain available for future reviews.

Best regards,
EastmarkHK
```
