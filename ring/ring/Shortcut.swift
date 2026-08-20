import SwiftUI
import Carbon.HIToolbox

struct Shortcut {
    let key: String
    let modifiers: SwiftUI.EventModifiers
    let keyCode: UInt32
    let carbonModifiers: UInt32

    init?(_ string: String?) {
        guard let string else {
            print("Shortcut init \(string ?? "No")")
            return nil
        }

        let parts = string
            .lowercased()
            .split(separator: "+")
            .map(String.init)

        guard let key = parts.last else {
            return nil
        }

        var swiftModifiers: SwiftUI.EventModifiers = []
        var carbonModifiers: UInt32 = 0

        for part in parts.dropLast() {
            switch part {
            case "cmd", "command":
                swiftModifiers.insert(.command)
                carbonModifiers |= UInt32(cmdKey)

            case "shift":
                swiftModifiers.insert(.shift)
                carbonModifiers |= UInt32(shiftKey)

            case "alt", "option":
                swiftModifiers.insert(.option)
                carbonModifiers |= UInt32(optionKey)

            case "ctrl", "control":
                swiftModifiers.insert(.control)
                carbonModifiers |= UInt32(controlKey)

            default:
                break
            }
        }

        guard let keyCode = Self.keyCode(for: key) else {
            return nil
        }

        self.key = key
        self.modifiers = swiftModifiers
        self.keyCode = keyCode
        self.carbonModifiers = carbonModifiers
    }

    var keyEquivalent: KeyEquivalent {
        print("keyEquivalent:", key)
        return KeyEquivalent(Character(key))
    }

    private static func keyCode(for key: String) -> UInt32? {
        switch key {
        case "a": UInt32(kVK_ANSI_A)
        case "b": UInt32(kVK_ANSI_B)
        case "c": UInt32(kVK_ANSI_C)
        case "d": UInt32(kVK_ANSI_D)
        case "e": UInt32(kVK_ANSI_E)
        case "f": UInt32(kVK_ANSI_F)
        case "g": UInt32(kVK_ANSI_G)
        case "h": UInt32(kVK_ANSI_H)
        case "i": UInt32(kVK_ANSI_I)
        case "j": UInt32(kVK_ANSI_J)
        case "k": UInt32(kVK_ANSI_K)
        case "l": UInt32(kVK_ANSI_L)
        case "m": UInt32(kVK_ANSI_M)
        case "n": UInt32(kVK_ANSI_N)
        case "o": UInt32(kVK_ANSI_O)
        case "p": UInt32(kVK_ANSI_P)
        case "q": UInt32(kVK_ANSI_Q)
        case "r": UInt32(kVK_ANSI_R)
        case "s": UInt32(kVK_ANSI_S)
        case "t": UInt32(kVK_ANSI_T)
        case "u": UInt32(kVK_ANSI_U)
        case "v": UInt32(kVK_ANSI_V)
        case "w": UInt32(kVK_ANSI_W)
        case "x": UInt32(kVK_ANSI_X)
        case "y": UInt32(kVK_ANSI_Y)
        case "z": UInt32(kVK_ANSI_Z)

        case "0": UInt32(kVK_ANSI_0)
        case "1": UInt32(kVK_ANSI_1)
        case "2": UInt32(kVK_ANSI_2)
        case "3": UInt32(kVK_ANSI_3)
        case "4": UInt32(kVK_ANSI_4)
        case "5": UInt32(kVK_ANSI_5)
        case "6": UInt32(kVK_ANSI_6)
        case "7": UInt32(kVK_ANSI_7)
        case "8": UInt32(kVK_ANSI_8)
        case "9": UInt32(kVK_ANSI_9)

        default: nil
        }
    }
}
