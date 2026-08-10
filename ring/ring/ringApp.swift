import Foundation
import SwiftUI
import AppKit

struct MenuItem: Codable {
    let name: String
    let url: String
}

func loadMenuItems() -> [MenuItem] {
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
    let items = loadMenuItems()

    var body: some Scene {
        MenuBarExtra("URL Handler", systemImage: "link") {
            Button("How to use") {
                let alert = NSAlert()
                   alert.messageText = "How to use Ring.app"
                   alert.informativeText = "1. define menus in \"~/ring.json\".\n2. define actions in \"~/ring.sh\", eg. to run script, app, or anything else.\n3. click the menu item or run \"open ring://WHAT_EVER_YOU_HAVE_DEFINED\" in terminal to trigger action.\n\nCheck out \"~/ring.sh\" and \"~/ring.json\" for more details."
                   alert.alertStyle = .informational
                   alert.addButton(withTitle: "OK")
                   alert.runModal()
            }
            
            Divider()
            ForEach(items.indices, id:\.self) { index in
                let item = items[index]
                Button(item.name) {
                    NSWorkspace.shared.open(URL(string: item.url)!)
                }
            }

            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }
}
