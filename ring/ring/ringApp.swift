import Foundation
import SwiftUI
import AppKit

let gRingJsonFile = "~/.ring.json"
let gRingScriptFile = "~/.ring.sh"

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
            NSString(string: gRingScriptFile).expandingTildeInPath,
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
        ensureRingJsonFile()
        ensureRingScriptFile()
        let loadedItems = loadMenuItems()
        _items = State(initialValue: loadedItems)
        hotKeyManager.action = { item in
            print("Global hotkey: \(item.name)")
            print("URL: \(item.url)")
            item.handle()
        }
        hotKeyManager.register(items: loadedItems)
    }

    private func ensureRingJsonFile() {
        let path = NSString(string: gRingJsonFile).expandingTildeInPath
        let url = URL(fileURLWithPath: path)

        guard !FileManager.default.fileExists(atPath: url.path) else {
            return
        }

        let content = """
        [
            {
                "name": "Systems",
                "items": [
                    {
                        "name": "Switch system appearence",
                        "url": "ring://switch-system-appearence",
                        "shortcut": "cmd+ctrl+f12"
                    }
                ]
            },
            {
                "name": "Alert",
                "url": "ring://alert/ALERT-MESSAGE-HERE"
            }
        ]
        """
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            print("Created \(url.path)")
        } catch {
            print("Failed to create \(url.path): \(error)")
        }
    }
    
    private func ensureExecutable(_ path: String) {
        let fm = FileManager.default
        guard fm.fileExists(atPath: path) else {
            print("File does not exist: \(path)")
            return
        }

        do {
            let attributes = try fm.attributesOfItem(atPath: path)
            guard let permissions = attributes[.posixPermissions] as? NSNumber else {
                print("Could not get permissions")
                return
            }
            let mode = permissions.uint16Value
            // Already executable by owner/group/others?
            if mode & 0o100 != 0 {
                print("Already executable")
                return
            }
            // Add execute permission while preserving existing permissions.
            try fm.setAttributes(
                [.posixPermissions: mode | 0o111],
                ofItemAtPath: path
            )
            print("Made executable: \(path)")
        } catch {
            print("Failed: \(error)")
        }
    }
    
    private func ensureRingScriptFile() {
        let path = NSString(string: gRingScriptFile).expandingTildeInPath
        let url = URL(fileURLWithPath: path)

        let fm = FileManager.default
        
        guard !fm.fileExists(atPath: url.path) else {
            ensureExecutable(url.path)
            return
        }

        let content = """
        #!/usr/bin/env bash
        # set -x

        # debug tool
        function alert {
            message="${1}"
            osascript -e "display dialog \\"${message}\\" buttons {\\"OK\\"} default button 1"
        }

        # sample deeplink format: ring://action/argument1[/argument2/...]
        url="${*}"

        echo ${url} >> /tmp/ring.sh.log

        IFS='/'
        read -ra array <<< "${url}"

        action="${array[2]}"
        args=("${array[@]:3}")

        case $action in
            'switch-system-appearence')
                osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
                ;;        

            'alert')
                alert "${args:-alert}"
                ;;
            *)
                ;;
        esac
        """
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            print("Created \(url.path)")
        } catch {
            print("Failed to create \(url.path): \(error)")
        }
        ensureExecutable(url.path)
    }

    private func reload() {
        items = loadMenuItems()
        hotKeyManager.register(items: items)
    }

    private func loadMenuItems() -> [MenuItem] {
        let path = NSString(string: gRingJsonFile).expandingTildeInPath
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([MenuItem].self, from: data)
        } catch {
            print("Failed to load \(gRingScriptFile): \(error)")
            let alert = NSAlert()
               alert.messageText = "Ring.app"
               alert.informativeText = "\(gRingJsonFile) is not a valid json, use some json-check tool to ensure the json is valid.\n\n\(error)"
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
                   alert.informativeText = "1. define menus in \"\(gRingJsonFile)\".\n2. define actions in \"\(gRingScriptFile)\", eg. to run script, app, or anything else.\n3. click the menu item to trigger action.\n\nTips: click the \"Reload\" menu to reload \"\(gRingJsonFile)\" after modifing the file.\n\nAnd, check out \"\(gRingJsonFile)\" and \"\(gRingScriptFile)\" for more details."
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
