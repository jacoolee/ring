import Carbon.HIToolbox

final class GlobalHotKeyManager {

    private struct RegisteredHotKey {
        let ref: EventHotKeyRef
        let item: MenuItem
    }

    private var hotKeys: [RegisteredHotKey] = []

    private var eventHandler: EventHandlerRef?

    var action: ((MenuItem) -> Void)?

    init() {
        installEventHandler()
    }

    deinit {
        unregisterAll()

        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    func register(items: [MenuItem]) {
        unregisterAll()

        for (index, item) in flatten(items).enumerated() {
            guard let shortcut = Shortcut(item.shortcut) else {
                continue
            }

            var ref: EventHotKeyRef?

            let id = EventHotKeyID(
                signature: OSType(0x52494E47),
                id: UInt32(index + 1)
            )

            let status = RegisterEventHotKey(
                shortcut.keyCode,
                shortcut.carbonModifiers,
                id,
                GetApplicationEventTarget(),
                0,
                &ref
            )

            if status == noErr, let ref {
                hotKeys.append(
                    RegisteredHotKey(
                        ref: ref,
                        item: item
                    )
                )
                print("Registered \(shortcut) → \(item.name)")
            }
        }
    }

    private func unregisterAll() {
        for hotKey in hotKeys {
            UnregisterEventHotKey(hotKey.ref)
        }

        hotKeys.removeAll()
    }

    private func installEventHandler() {
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let result = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in

                guard let userData else {
                    return noErr
                }

                let manager = Unmanaged<GlobalHotKeyManager>
                    .fromOpaque(userData)
                    .takeUnretainedValue()

                var hotKeyID = EventHotKeyID()

                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                manager.handle(hotKeyID)

                return noErr

            },
            1,
            &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )

        if result != noErr {
            print("Failed to install global hotkey event handler")
        }
    }

    private func handle(_ hotKeyID: EventHotKeyID) {
        let index = Int(hotKeyID.id) - 1

        guard index >= 0,
              index < hotKeys.count
        else {
            return
        }

        let item = hotKeys[index].item

        DispatchQueue.main.async {
            self.action?(item)
        }
    }

    private func flatten(_ items: [MenuItem]) -> [MenuItem] {
        var result: [MenuItem] = []

        for item in items {
            if item.shortcut != nil {
                result.append(item)
            }

            result.append(contentsOf: flatten(item.items))
        }

        return result
    }
}
