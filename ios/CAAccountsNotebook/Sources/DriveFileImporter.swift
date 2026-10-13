import Foundation

/// Copies a file chosen via the Files picker (including Google Drive) into app storage.
/// This is a one-time copy; it is not kept in sync with Drive.
enum DriveFileImporter {
    static func importFile(from url: URL, into store: NotebookStore) throws -> String {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        let name = "\(UUID().uuidString)-\(url.lastPathComponent)"
        try FileManager.default.copyItem(at: url, to: store.attachmentURL(name))
        return name
    }
}
