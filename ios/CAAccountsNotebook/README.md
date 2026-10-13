# CA Accounts Notebook (iPad)

SwiftUI + PencilKit notebook for CA Inter Accounts. Local-first; Drive files are imported via the Files picker (one-time copy); iCloud sync is a CloudKit stub (`CloudSync.swift`).

## Setup (Mac + Xcode)
1. New Xcode project: iOS App, SwiftUI, iPad supported, name `CAAccountsNotebook`.
2. Delete the template `ContentView.swift` and app file; add everything in `Sources/` to the target.
3. Run on an iPad simulator. Deployment target iOS 17+ (uses two-parameter `onChange`).
4. For sync later: add iCloud capability with CloudKit and a container.
