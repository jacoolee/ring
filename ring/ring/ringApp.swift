import Foundation
import SwiftUI
import AppKit



class AppDelegate: NSObject, NSApplicationDelegate {

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            print("Received:", url.absoluteString)
            handleDeepLink(url)
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.windows.first?.orderOut(nil)
    }
    
    func handleDeepLink(_ url: URL) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash") // Use bash to run the script
        process.arguments = [
            NSString(string: "~/ring.sh").expandingTildeInPath,
            url.absoluteString
        ] // Pass arguments to the script
     do {
        try process.run()
        process.waitUntilExit()
     } catch {
            print("Error running script: \(error)")
        }
    }
}

@main
struct ringApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var delegate

    @State private var items: [MenuItem] = []
    private let hotKeyManager = GlobalHotKeyManager()

    init() {
        let loadedItems = loadMenuItems()
        _items = State(initialValue: loadedItems)
        hotKeyManager.action = { item in
            print("Global hotkey: \(item.name)")
            print("URL: \(item.url)")
            item.handle()
        }
        hotKeyManager.register(items: loadedItems)
    }

    private func reload() {
        items = loadMenuItems()
        hotKeyManager.register(items: items)
    }

    private func loadMenuItems() -> [MenuItem] {
        let jsonfile = "~/ring.json"
        let path = NSString(string: jsonfile).expandingTildeInPath
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([MenuItem].self, from: data)
        } catch {
            print("Failed to load ring.json: \(error)")
            let alert = NSAlert()
               alert.messageText = "Ring.app"
               alert.informativeText = "\(jsonfile) is not a valid json, use some json-check tool to ensure the json is valid.\n\n\(error)"
               alert.alertStyle = .informational
               alert.addButton(withTitle: "OK")
               alert.runModal()
            return []
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
            ForEach(items.indices, id: \.self) { index in
                MenuItemView(item: items[index])
            }

            Divider()
            Button("How to use") {
                let alert = NSAlert()
                   alert.messageText = "How to use Ring.app"
                   alert.informativeText = "1. define menus in \"~/ring.json\".\n2. define actions in \"~/ring.sh\", eg. to run script, app, or anything else.\n3. click the menu item to trigger action.\n\nTips: click the \"Reload\" menu to reload \"~/ring.json\" after modifing the file.\n\nAnd, check out \"~/ring.sh\" and \"~/ring.json\" for more details."
                   alert.alertStyle = .informational
                   alert.addButton(withTitle: "OK")
                   alert.runModal()
            }
            Button("Reload") {
                reload()
            }
            Button("Quit") {
                NSApp.terminate(nil)
            }
        } label: {
            Image(nsImage: {
                let image = NSImage(
                    systemSymbolName: "circle",
                    accessibilityDescription: "Ring"
                )!
                return image.withSymbolConfiguration(
                    NSImage.SymbolConfiguration(
                        pointSize: 15,
                        weight: .bold
                    )
                )!
            }())
        }
    }
}
