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
            Text("run 'open ring://whatever' in terminal, and create and modify /Applications/ring.sh to run your script.")
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }
}
