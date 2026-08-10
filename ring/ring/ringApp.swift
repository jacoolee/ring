import Foundation
import SwiftUI
import AppKit

struct MenuItem {
    let name: String
    let url: String
}

let items: [MenuItem] = [
    MenuItem(
        name: "Switch theme",
        url: "ring://switch-theme",
    ),
    MenuItem(
        name: "Open system preferences",
        url: "ring://open-system-preferences",
    ),
    MenuItem(
        name: "debug",
        url: "ring://debug",
    )
]

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
        process.arguments = ["/Applications/ring.sh", url.absoluteString ] // Pass arguments to the script
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
    
    var body: some Scene {
        MenuBarExtra("URL Handler", systemImage: "link") {
            Button("How to use") {
                let alert = NSAlert()
                   alert.messageText = "Ring"
                   alert.informativeText = "Modify /Applications/ring.sh (create if not exists) to run anything your want, and use open \"ring://whatever\" to trigger."
                   alert.alertStyle = .informational
                   alert.addButton(withTitle: "OK")
                   alert.runModal()
            }
            
            Divider()
            
            ForEach(items, id:\.name) { item in
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
