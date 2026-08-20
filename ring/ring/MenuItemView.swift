import Foundation
import SwiftUI

struct MenuItemView: View {
    let item: MenuItem

    @ViewBuilder
    var body: some View {
        if item.type == "divider" {
            Divider()
        } else if !item.items.isEmpty {
            Menu(item.name) {
                ForEach(item.items.indices, id: \.self) { index in
                    MenuItemView(item: item.items[index])
                }
            }
        } else {
            if let shortcut = Shortcut(item.shortcut) {
                Button(item.name) {
                    item.handle()
                }
                .keyboardShortcut(
                    shortcut.keyEquivalent,
                    modifiers: shortcut.modifiers
                )
            }
            else {
                Button(item.name) {
                    item.handle()
                }
            }
        }
    }
}
