import SwiftUI

@main
struct CAAccountsNotebookApp: App {
    @StateObject private var store = NotebookStore()
    var body: some Scene {
        WindowGroup { NotebookView().environmentObject(store) }
    }
}
