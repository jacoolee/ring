import Foundation
import SwiftUI

@main
struct ringApp: App {
    init() {
        print("Ring to rule them all")
    }
    
    func handleDeepLink(_ url: URL) {
        let scriptPath = "/Applications/ring.sh" // Replace with the actual path to your script

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash") // Use bash to run the script
        process.arguments = [scriptPath, url.absoluteString ] // Pass arguments to the script

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                print("Output from script: \(output)")
            }
        } catch {
            print("Error running script: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    print("App opened with URL: \(url)")
                    handleDeepLink(url)
                }
        }
    }
}
