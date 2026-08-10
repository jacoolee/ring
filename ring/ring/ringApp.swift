import Foundation
import SwiftUI
import AppKit

struct MenuItem: Codable {
    let name: String
    let url: String
    let items: [MenuItem]

    enum CodingKeys: String, CodingKey {
        case name, url, items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        items = try container.decodeIfPresent([MenuItem].self, forKey: .items) ?? []
    }
}

struct MenuItemView: View {
    let item: MenuItem

    @ViewBuilder
    var body: some View {
        if !item.items.isEmpty {
            Menu(item.name) {
                ForEach(item.items.indices, id: \.self) { index in
                    MenuItemView(item: item.items[index])
                }
            }
        } else {
            Button(item.name) {
                handleMenuItem(item)
            }
        }
    }

    private func handleMenuItem(_ item: MenuItem) {
        print("Clicked: \(item.name) \(item.url)")
        NSWorkspace.shared.open(URL(string: item.url)!)
    }
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
        MenuBarExtra("Ring", systemImage: "circle") {
            ForEach(items.indices, id: \.self) { index in
                MenuItemView(item: items[index])
            }

            Divider()
            Button("How to use") {
                let alert = NSAlert()
                   alert.messageText = "How to use Ring.app"
                   alert.informativeText = "1. define menus in \"~/ring.json\".\n2. define actions in \"~/ring.sh\", eg. to run script, app, or anything else.\n3. click the menu item or run \"open ring://WHAT_EVER_YOU_HAVE_DEFINED\" in terminal to trigger action.\n\nCheck out \"~/ring.sh\" and \"~/ring.json\" for more details."
                   alert.alertStyle = .informational
                   alert.addButton(withTitle: "OK")
                   alert.runModal()
            }
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }
}
