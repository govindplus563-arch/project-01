import SwiftUI
import PencilKit
import UniformTypeIdentifiers
import PDFKit

struct TableGrid: View {
    let template: TableTemplate
    var body: some View {
        GeometryReader { geo in
            let colW = geo.size.width / CGFloat(template.columns.count)
            let headerH: CGFloat = 36
            let rowH = (geo.size.height - headerH) / CGFloat(template.rows)
            ZStack(alignment: .topLeading) {
                Path { p in
                    for c in 0...template.columns.count {
                        p.move(to: CGPoint(x: CGFloat(c) * colW, y: 0))
                        p.addLine(to: CGPoint(x: CGFloat(c) * colW, y: geo.size.height))
                    }
                    for r in 0...template.rows {
                        let y = headerH + CGFloat(r) * rowH
                        p.move(to: CGPoint(x: 0, y: r == 0 ? 0 : y)); p.addLine(to: CGPoint(x: geo.size.width, y: r == 0 ? 0 : y))
                    }
                    p.move(to: CGPoint(x: 0, y: headerH)); p.addLine(to: CGPoint(x: geo.size.width, y: headerH))
                }.stroke(Color.secondary.opacity(0.6), lineWidth: 1)
                ForEach(Array(template.columns.enumerated()), id: \.offset) { i, name in
                    Text(name).font(.caption.bold()).frame(width: colW, height: headerH)
                        .offset(x: CGFloat(i) * colW)
                }
            }
        }
    }
}

struct PageEditor: View {
    @EnvironmentObject var store: NotebookStore
    @State var page: NotebookPage
    @State private var canvas = PKCanvasView()
    @State private var erasing = false
    @State private var importing = false
    @State private var errorText: String?
    @State private var previewing: URL?

    var template: TableTemplate { .find(page.templateID) }
    var tool: PKTool { erasing ? PKEraserTool(.bitmap) : PKInkingTool(.pen, color: .label, width: 3) }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                TableGrid(template: template)
                CanvasView(drawingData: $page.drawingData, tool: tool) { canvas = $0 }
            }
            .frame(minHeight: 520)
            .background(Color(.systemBackground))
            TextEditor(text: $page.typedNotes)
                .frame(height: 140).padding(8)
                .overlay(alignment: .topLeading) {
                    if page.typedNotes.isEmpty { Text("Chapter notes…").foregroundStyle(.secondary).padding(16) }
                }
            if !page.attachmentNames.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(page.attachmentNames, id: \.self) { n in
                            Button(n.split(separator: "-", maxSplits: 5).last.map(String.init) ?? n) {
                                previewing = store.attachmentURL(n)
                            }.buttonStyle(.bordered)
                        }
                    }.padding(.horizontal)
                }
            }
        }
        .navigationTitle(page.title)
        .toolbar {
            ToolbarItemGroup {
                Button { canvas.undoManager?.undo() } label: { Image(systemName: "arrow.uturn.backward") }
                Button { canvas.undoManager?.redo() } label: { Image(systemName: "arrow.uturn.forward") }
                Toggle(isOn: $erasing) { Image(systemName: "eraser") }
                Button(role: .destructive) { canvas.drawing = PKDrawing(); page.drawingData = Data() } label: { Image(systemName: "trash") }
                Button { importing = true } label: { Label("Import from Drive", systemImage: "square.and.arrow.down") }
            }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.pdf, .image]) { result in
            do {
                let name = try DriveFileImporter.importFile(from: try result.get(), into: store)
                page.attachmentNames.append(name)
            } catch { errorText = error.localizedDescription }
        }
        .sheet(item: Binding(get: { previewing.map(IdentifiableURL.init) }, set: { previewing = $0?.url })) {
            AttachmentPreview(url: $0.url)
        }
        .alert("Import failed", isPresented: Binding(get: { errorText != nil }, set: { _ in errorText = nil })) {
            Button("OK") {}
        } message: { Text(errorText ?? "") }
        .onChange(of: page) { _, new in store.save(new) }   // autosave on every edit
        .onDisappear { store.save(page) }
    }
}

struct IdentifiableURL: Identifiable { let url: URL; var id: URL { url } }

struct AttachmentPreview: View {
    let url: URL
    var body: some View {
        if url.pathExtension.lowercased() == "pdf" {
            PDFRepresentable(url: url)
        } else if let img = UIImage(contentsOfFile: url.path) {
            ScrollView([.horizontal, .vertical]) { Image(uiImage: img) }
        } else { Text("Cannot preview file") }
    }
}

struct PDFRepresentable: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let v = PDFView(); v.document = PDFDocument(url: url); v.autoScales = true; return v
    }
    func updateUIView(_ v: PDFView, context: Context) {}
}
