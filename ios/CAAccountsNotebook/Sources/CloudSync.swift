import Foundation
import CloudKit

/// Stub for step 8. One CKRecord per page in the private database.
/// TODO: enable iCloud + CloudKit capability, register container, add conflict handling
/// (e.g. compare updatedAt / use CKRecord change tags) before multi-device editing.
actor CloudSync {
    private let db = CKContainer.default().privateCloudDatabase

    func push(_ page: NotebookPage) async throws {
        let record = CKRecord(recordType: "NotebookPage", recordID: .init(recordName: page.id.uuidString))
        record["chapter"] = page.chapter
        record["title"] = page.title
        record["templateID"] = page.templateID
        record["typedNotes"] = page.typedNotes
        record["drawingData"] = page.drawingData
        record["updatedAt"] = page.updatedAt
        _ = try await db.modifyRecords(saving: [record], deleting: [], savePolicy: .changedKeys)
    }
}
