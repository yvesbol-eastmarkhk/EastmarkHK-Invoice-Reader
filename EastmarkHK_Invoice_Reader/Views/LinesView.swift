import SwiftUI

struct LinesView: View {
    @EnvironmentObject private var l10n: L10n
    let invoice: PeppolInvoice?

    var body: some View {
        if let invoice {
            Table(invoice.lines) {
                TableColumn(l10n.t("colNumber")) { line in
                    Text(line.lineID)
                }
                .width(40)
                TableColumn(l10n.t("colDescription")) { line in
                    VStack(alignment: .leading, spacing: 2) {
                        if !line.pdfTitle.isEmpty {
                            Text(line.pdfTitle)
                                .fontWeight(.medium)
                        }
                        Text(line.pdfDescription)
                            .foregroundStyle(line.pdfTitle.isEmpty ? .primary : .secondary)
                            .font(line.pdfTitle.isEmpty ? .body : .caption)
                    }
                }
                TableColumn(l10n.t("colQty")) { line in
                    Text(line.quantityLabel)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .width(80)
                TableColumn(l10n.t("colUnitPrice")) { line in
                    Text(PeppolFormatting.money(line.unitPrice, currency: invoice.currency))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .width(100)
                TableColumn(l10n.t("colVatPercent")) { line in
                    Text(PeppolFormatting.percent(line.vatPercent))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .width(60)
                TableColumn(l10n.t("colLineTotal")) { line in
                    Text(PeppolFormatting.money(line.lineTotal, currency: invoice.currency))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .width(100)
            }
            .padding(16)
        } else {
            ContentUnavailableView(
                l10n.t("emptyInvoice"),
                systemImage: "list.bullet.rectangle",
                description: Text(l10n.t("emptyInvoiceHint"))
            )
        }
    }
}
