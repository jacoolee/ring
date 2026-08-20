import SwiftUI
import Carbon.HIToolbox

struct Shortcut {
    let key: String
    let modifiers: SwiftUI.EventModifiers
    let keyCode: UInt32
    let carbonModifiers: UInt32

    init?(_ string: String?) {
        guard let string else {
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

    // MARK: - SwiftUI

    var keyEquivalent: KeyEquivalent {
        switch key {
        case "f1":  return KeyEquivalent("\u{F704}")
        case "f2":  return KeyEquivalent("\u{F705}")
        case "f3":  return KeyEquivalent("\u{F706}")
        case "f4":  return KeyEquivalent("\u{F707}")
        case "f5":  return KeyEquivalent("\u{F708}")
        case "f6":  return KeyEquivalent("\u{F709}")
        case "f7":  return KeyEquivalent("\u{F70A}")
        case "f8":  return KeyEquivalent("\u{F70B}")
        case "f9":  return KeyEquivalent("\u{F70C}")
        case "f10": return KeyEquivalent("\u{F70D}")
        case "f11": return KeyEquivalent("\u{F70E}")
        case "f12": return KeyEquivalent("\u{F70F}")

        default:
            return KeyEquivalent(Character(key))
        }
    }

    // MARK: - Carbon

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

        case "f1": UInt32(kVK_F1)
        case "f2": UInt32(kVK_F2)
        case "f3": UInt32(kVK_F3)
        case "f4": UInt32(kVK_F4)
        case "f5": UInt32(kVK_F5)
        case "f6": UInt32(kVK_F6)
        case "f7": UInt32(kVK_F7)
        case "f8": UInt32(kVK_F8)
        case "f9": UInt32(kVK_F9)
        case "f10": UInt32(kVK_F10)
        case "f11": UInt32(kVK_F11)
        case "f12": UInt32(kVK_F12)

        case "space": UInt32(kVK_Space)
        case "return", "enter": UInt32(kVK_Return)
        case "escape", "esc": UInt32(kVK_Escape)
        case "tab": UInt32(kVK_Tab)

        default:
            nil
        }
    }
}
