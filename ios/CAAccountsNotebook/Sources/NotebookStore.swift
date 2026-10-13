import Foundation

/// Local-first store: one JSON file per page in Documents/Pages. Works offline.
@MainActor
final class NotebookStore: ObservableObject {
    @Published private(set) var pages: [NotebookPage] = []

    private let fm = FileManager.default
    private let root: URL
    var pagesDir: URL { root.appendingPathComponent("Pages") }
    var attachmentsDir: URL { root.appendingPathComponent("Attachments") }

    init(root: URL? = nil) {
        self.root = root ?? fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try? fm.createDirectory(at: pagesDir, withIntermediateDirectories: true)
        try? fm.createDirectory(at: attachmentsDir, withIntermediateDirectories: true)
        load()
    }

    func pages(in chapter: String) -> [NotebookPage] {
        pages.filter { $0.chapter == chapter }.sorted { $0.updatedAt > $1.updatedAt }
    }

    @discardableResult
    func createPage(chapter: String, title: String, templateID: String) -> NotebookPage {
        let page = NotebookPage(chapter: chapter, title: title, templateID: templateID)
        save(page)
        return page
    }

    func save(_ page: NotebookPage) {
        var p = page
        p.updatedAt = Date()
        if let i = pages.firstIndex(where: { $0.id == p.id }) { pages[i] = p } else { pages.append(p) }
        if let data = try? JSONEncoder().encode(p) {
            try? data.write(to: file(for: p.id), options: .atomic)
        }
    }

    func rename(_ page: NotebookPage, to title: String) {
        var p = page; p.title = title; save(p)
    }

    func delete(_ page: NotebookPage) {
        pages.removeAll { $0.id == page.id }
        try? fm.removeItem(at: file(for: page.id))
        for name in page.attachmentNames { try? fm.removeItem(at: attachmentURL(name)) }
    }

    func attachmentURL(_ name: String) -> URL { attachmentsDir.appendingPathComponent(name) }

    private func file(for id: UUID) -> URL { pagesDir.appendingPathComponent("\(id.uuidString).json") }

    private func load() {
        let files = (try? fm.contentsOfDirectory(at: pagesDir, includingPropertiesForKeys: nil)) ?? []
        pages = files.compactMap { try? JSONDecoder().decode(NotebookPage.self, from: Data(contentsOf: $0)) }
    }
}
