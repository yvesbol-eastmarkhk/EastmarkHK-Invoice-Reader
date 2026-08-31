import SwiftUI

struct SummaryView: View {
    @EnvironmentObject private var l10n: L10n
    let invoice: PeppolInvoice?

    var body: some View {
        if let invoice {
            HStack(alignment: .top, spacing: 16) {
                PartyBox(title: l10n.t("supplier"), party: invoice.supplier)
                PartyBox(title: l10n.t("customer"), party: invoice.customer)
                VStack(alignment: .leading, spacing: 16) {
                    GroupBox(l10n.t("invoiceDetails")) {
                        FormRow(
                            label: l10n.t("pdfSource"),
                            value: invoice.hasEmbeddedPDF ? l10n.t("pdfEmbedded") : l10n.t("pdfGenerated")
                        )
                        FormRow(
                            label: l10n.t("number"),
                            value: invoice.invoiceID.isEmpty ? l10n.t("emptyDash") : invoice.invoiceID
                        )
                        FormRow(
                            label: l10n.t("issueDate"),
                            value: invoice.issueDate.isEmpty ? l10n.t("emptyDash") : invoice.issueDate
                        )
                        FormRow(
                            label: l10n.t("dueDate"),
                            value: invoice.dueDate.isEmpty ? l10n.t("emptyDash") : invoice.dueDate
                        )
                        FormRow(label: l10n.t("currency"), value: invoice.currency)
                        if !invoice.buyerReference.isEmpty {
                            FormRow(label: l10n.t("buyerRef"), value: invoice.buyerReference)
                        }
                        if !invoice.orderReference.isEmpty {
                            FormRow(label: l10n.t("orderRef"), value: invoice.orderReference)
                        }
                        if !invoice.note.isEmpty {
                            FormRow(label: l10n.t("note"), value: invoice.note)
                        }
                    }
                    GroupBox(l10n.t("totals")) {
                        FormRow(
                            label: l10n.t("subtotalLines"),
                            value: PeppolFormatting.money(invoice.lineExtensionAmount, currency: invoice.currency)
                        )
                        FormRow(
                            label: l10n.t("exclVat"),
                            value: PeppolFormatting.money(invoice.taxExclusiveAmount, currency: invoice.currency)
                        )
                        FormRow(
                            label: l10n.t("vat"),
                            value: PeppolFormatting.money(invoice.totalVAT, currency: invoice.currency)
                        )
                        FormRow(
                            label: l10n.t("inclVat"),
                            value: PeppolFormatting.money(invoice.taxInclusiveAmount, currency: invoice.currency),
                            bold: true
                        )
                        FormRow(
                            label: l10n.t("amountDue"),
                            value: PeppolFormatting.money(invoice.payableAmount, currency: invoice.currency),
                            bold: true
                        )
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: 320)
            }
            .padding(16)
        } else {
            ContentUnavailableView(
                l10n.t("emptyInvoice"),
                systemImage: "doc.text",
                description: Text(l10n.t("emptyInvoiceHint"))
            )
        }
    }
}

private struct PartyBox: View {
    @EnvironmentObject private var l10n: L10n
    let title: String
    let party: Party

    var body: some View {
        GroupBox(title) {
            VStack(alignment: .leading, spacing: 4) {
                Text(party.name.isEmpty ? l10n.t("emptyDash") : party.name)
                    .fontWeight(.semibold)
                ForEach(party.addressLines, id: \.self) { line in
                    Text(line)
                }
                if !party.vatNumber.isEmpty {
                    Text(l10n.t("vatPrefix", ["value": party.vatNumber]))
                }
                if !party.email.isEmpty {
                    Text(party.email)
                }
                if !party.phone.isEmpty {
                    Text(party.phone)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FormRow: View {
    let label: String
    let value: String
    var bold = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(bold ? .semibold : .regular)
                .multilineTextAlignment(.trailing)
        }
    }
}
