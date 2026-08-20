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

        let flattened = flatten(items)

        for (index, item) in flattened.enumerated() {
            guard let shortcut = item.shortcut,
                  let parsed = parseShortcut(shortcut)
            else {
                continue
            }

            var hotKeyRef: EventHotKeyRef?

            let hotKeyID = EventHotKeyID(
                signature: OSType(0x52494E47), // "RING"
                id: UInt32(index + 1)
            )

            let status = RegisterEventHotKey(
                parsed.keyCode,
                parsed.modifiers,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )

            guard status == noErr,
                  let hotKeyRef
            else {
                print("Failed to register hotkey: \(shortcut)")
                continue
            }

            hotKeys.append(
                RegisteredHotKey(
                    ref: hotKeyRef,
                    item: item
                )
            )

            print("Registered \(shortcut) → \(item.name)")
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

    // MARK: - Shortcut parsing

    private func parseShortcut(
        _ shortcut: String
    ) -> (keyCode: UInt32, modifiers: UInt32)? {

        let parts = shortcut
            .lowercased()
            .split(separator: "+")
            .map(String.init)

        guard let key = parts.last else {
            return nil
        }

        var modifiers: UInt32 = 0

        for part in parts.dropLast() {
            switch part {
            case "cmd", "command":
                modifiers |= UInt32(cmdKey)

            case "shift":
                modifiers |= UInt32(shiftKey)

            case "ctrl", "control":
                modifiers |= UInt32(controlKey)

            case "alt", "option":
                modifiers |= UInt32(optionKey)

            default:
                break
            }
        }

        guard let keyCode = keyCode(for: key) else {
            return nil
        }

        return (keyCode, modifiers)
    }

    private func keyCode(for key: String) -> UInt32? {
        switch key {
        case "a": return UInt32(kVK_ANSI_A)
        case "b": return UInt32(kVK_ANSI_B)
        case "c": return UInt32(kVK_ANSI_C)
        case "d": return UInt32(kVK_ANSI_D)
        case "e": return UInt32(kVK_ANSI_E)
        case "f": return UInt32(kVK_ANSI_F)
        case "g": return UInt32(kVK_ANSI_G)
        case "h": return UInt32(kVK_ANSI_H)
        case "i": return UInt32(kVK_ANSI_I)
        case "j": return UInt32(kVK_ANSI_J)
        case "k": return UInt32(kVK_ANSI_K)
        case "l": return UInt32(kVK_ANSI_L)
        case "m": return UInt32(kVK_ANSI_M)
        case "n": return UInt32(kVK_ANSI_N)
        case "o": return UInt32(kVK_ANSI_O)
        case "p": return UInt32(kVK_ANSI_P)
        case "q": return UInt32(kVK_ANSI_Q)
        case "r": return UInt32(kVK_ANSI_R)
        case "s": return UInt32(kVK_ANSI_S)
        case "t": return UInt32(kVK_ANSI_T)
        case "u": return UInt32(kVK_ANSI_U)
        case "v": return UInt32(kVK_ANSI_V)
        case "w": return UInt32(kVK_ANSI_W)
        case "x": return UInt32(kVK_ANSI_X)
        case "y": return UInt32(kVK_ANSI_Y)
        case "z": return UInt32(kVK_ANSI_Z)

        case "0": return UInt32(kVK_ANSI_0)
        case "1": return UInt32(kVK_ANSI_1)
        case "2": return UInt32(kVK_ANSI_2)
        case "3": return UInt32(kVK_ANSI_3)
        case "4": return UInt32(kVK_ANSI_4)
        case "5": return UInt32(kVK_ANSI_5)
        case "6": return UInt32(kVK_ANSI_6)
        case "7": return UInt32(kVK_ANSI_7)
        case "8": return UInt32(kVK_ANSI_8)
        case "9": return UInt32(kVK_ANSI_9)

        case "space":
            return UInt32(kVK_Space)

        case "return", "enter":
            return UInt32(kVK_Return)

        case "escape", "esc":
            return UInt32(kVK_Escape)

        case "tab":
            return UInt32(kVK_Tab)

        case "delete":
            return UInt32(kVK_Delete)

        case "left":
            return UInt32(kVK_LeftArrow)

        case "right":
            return UInt32(kVK_RightArrow)

        case "up":
            return UInt32(kVK_UpArrow)

        case "down":
            return UInt32(kVK_DownArrow)

        case "f1": return UInt32(kVK_F1)
        case "f2": return UInt32(kVK_F2)
        case "f3": return UInt32(kVK_F3)
        case "f4": return UInt32(kVK_F4)
        case "f5": return UInt32(kVK_F5)
        case "f6": return UInt32(kVK_F6)
        case "f7": return UInt32(kVK_F7)
        case "f8": return UInt32(kVK_F8)
        case "f9": return UInt32(kVK_F9)
        case "f10": return UInt32(kVK_F10)
        case "f11": return UInt32(kVK_F11)
        case "f12": return UInt32(kVK_F12)

        default:
            return nil
        }
    }
}
