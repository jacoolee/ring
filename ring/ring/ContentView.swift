import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack {
            Text("Usage: open ring://xxxxx")
            Text("")
            Text("Modify /Applications/ring.sh (created one if not exist) to run your script")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
