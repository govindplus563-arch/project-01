import SwiftUI
import PencilKit

/// Transparent PencilKit canvas layered over the table grid.
struct CanvasView: UIViewRepresentable {
    @Binding var drawingData: Data
    var tool: PKTool
    var canvasRef: (PKCanvasView) -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        let v = PKCanvasView()
        v.backgroundColor = .clear
        v.isOpaque = false
        v.drawingPolicy = .anyInput          // Pencil and finger
        v.delegate = context.coordinator
        if let d = try? PKDrawing(data: drawingData) { v.drawing = d }
        canvasRef(v)
        return v
    }

    func updateUIView(_ v: PKCanvasView, context: Context) { v.tool = tool }
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: CanvasView
        init(_ p: CanvasView) { parent = p }
        func canvasViewDrawingDidChange(_ v: PKCanvasView) { parent.drawingData = v.drawing.dataRepresentation() }
    }
}
