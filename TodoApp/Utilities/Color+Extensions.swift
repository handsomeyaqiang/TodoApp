import SwiftUI
import UIKit

extension Color {
    init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned = String(cleaned.dropFirst()) }

        let length = cleaned.count
        guard length == 6 || length == 3 else { return nil }

        if length == 3 {
            cleaned = cleaned.map { "\($0)\($0)" }.joined()
        }

        var rgb: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&rgb) else { return nil }

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

extension Color {
    static let tagColors: [Color] = [
        Color(hex: "#007AFF")!, // blue
        Color(hex: "#34C759")!, // green
        Color(hex: "#FF9500")!, // orange
        Color(hex: "#FF3B30")!, // red
        Color(hex: "#AF52DE")!, // purple
        Color(hex: "#FF2D55")!, // pink
        Color(hex: "#5AC8FA")!, // cyan
        Color(hex: "#FFCC00")!, // yellow
    ]
}
