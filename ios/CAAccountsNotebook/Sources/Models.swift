import Foundation

struct TableTemplate: Identifiable, Hashable {
    let id: String
    let title: String
    let columns: [String]
    let rows: Int

    static let all: [TableTemplate] = [
        .init(id: "journal", title: "Journal", columns: ["Date", "Particulars", "L.F.", "Debit (₹)", "Credit (₹)"], rows: 18),
        .init(id: "ledger", title: "Ledger", columns: ["Date", "Particulars", "J.F.", "Amount (₹)", "Date", "Particulars", "J.F.", "Amount (₹)"], rows: 18),
        .init(id: "trial", title: "Trial Balance", columns: ["Particulars", "Debit (₹)", "Credit (₹)"], rows: 20),
        .init(id: "bs", title: "Balance Sheet", columns: ["Liabilities", "Amount (₹)", "Assets", "Amount (₹)"], rows: 16),
        .init(id: "pl", title: "Profit & Loss", columns: ["Particulars", "Amount (₹)", "Particulars", "Amount (₹)"], rows: 16),
        .init(id: "cf", title: "Cash Flow", columns: ["Particulars", "Amount (₹)", "Amount (₹)"], rows: 20),
        .init(id: "brs", title: "Bank Reconciliation Statement", columns: ["Particulars", "Plus (₹)", "Minus (₹)"], rows: 16),
    ]

    static func find(_ id: String) -> TableTemplate { all.first { $0.id == id } ?? all[0] }
}

/// CA Inter Accounts (Paper 1) chapter list — verify against the current ICAI syllabus.
let chapters = [
    "Framework for Preparation of Financial Statements",
    "Applicability of Accounting Standards",
    "Presentation of Financial Statements (Ind AS 1)",
    "Accounting for Special Transactions",
    "Partnership Accounts",
    "Company Accounts",
    "Financial Statements of Companies",
    "Accounting for Branches",
    "Cash Flow Statement",
    "Bank Reconciliation Statement",
]

struct NotebookPage: Identifiable, Codable, Hashable {
    var id = UUID()
    var chapter: String
    var title: String
    var templateID: String
    var typedNotes = ""
    var drawingData = Data()
    var attachmentNames: [String] = []
    var updatedAt = Date()
}
