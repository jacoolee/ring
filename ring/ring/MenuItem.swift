import Foundation
import AppKit

struct MenuItem: Codable {
    let type: String
    let name: String
    let url: String
    let items: [MenuItem]
    let shortcut: String?

    enum CodingKeys: String, CodingKey {
        case type, name, url, items, shortcut
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        items = try container.decodeIfPresent([MenuItem].self, forKey: .items) ?? []
        shortcut = try container.decodeIfPresent(String.self, forKey: .shortcut)
    }
    
    func handle() {
        NSWorkspace.shared.open(URL(string: self.url)!)
    }
}
