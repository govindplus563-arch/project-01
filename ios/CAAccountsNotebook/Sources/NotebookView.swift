import SwiftUI

struct NotebookView: View {
    @EnvironmentObject var store: NotebookStore
    @State private var chapter: String? = chapters.first
    @State private var selected: NotebookPage?
    @State private var creating = false
    @State private var renaming: NotebookPage?
    @State private var newTitle = ""

    var body: some View {
        NavigationSplitView {
            List(chapters, id: \.self, selection: $chapter) { Text($0) }.navigationTitle("Chapters")
        } content: {
            List(selection: $selected) {
                ForEach(store.pages(in: chapter ?? "")) { p in
                    VStack(alignment: .leading) {
                        Text(p.title); Text(TableTemplate.find(p.templateID).title).font(.caption).foregroundStyle(.secondary)
                    }
                    .tag(p)
                    .contextMenu {
                        Button("Rename") { renaming = p; newTitle = p.title }
                        Button("Delete", role: .destructive) { store.delete(p); if selected == p { selected = nil } }
                    }
                }
            }
            .navigationTitle(chapter ?? "Pages")
            .toolbar { Button { creating = true } label: { Label("New Page", systemImage: "plus") }.disabled(chapter == nil) }
        } detail: {
            if let p = selected { PageEditor(page: p).id(p.id) } else { Text("Select or create a page").foregroundStyle(.secondary) }
        }
        .sheet(isPresented: $creating) {
            NewPageSheet(initialChapter: chapter ?? chapters[0]) { ch, title, tpl in
                selected = store.createPage(chapter: ch, title: title, templateID: tpl); chapter = ch
            }
        }
        .alert("Rename page", isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
            TextField("Title", text: $newTitle)
            Button("Save") { if let p = renaming { store.rename(p, to: newTitle) } }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct NewPageSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var chapter: String
    @State private var title = ""
    @State private var templateID = TableTemplate.all[0].id
    let onCreate: (String, String, String) -> Void

    init(initialChapter: String, onCreate: @escaping (String, String, String) -> Void) {
        _chapter = State(initialValue: initialChapter); self.onCreate = onCreate
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Page title", text: $title)
                Picker("Chapter", selection: $chapter) { ForEach(chapters, id: \.self, content: Text.init) }
                Picker("Table format", selection: $templateID) { ForEach(TableTemplate.all) { Text($0.title).tag($0.id) } }
            }
            .navigationTitle("New Page")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { onCreate(chapter, title.isEmpty ? "Untitled" : title, templateID); dismiss() }
                }
            }
        }
    }
}
