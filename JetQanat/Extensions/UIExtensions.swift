import UIKit

extension UIColor {
    // Инициализатор HEX
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 1.0

        let length = hexSanitized.count
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    // Ваши цвета
    static let darkBg = UIColor(hex: "0A0A0A")
    static let cardBg = UIColor(hex: "1C1C1E")
    static let accentRed = UIColor(hex: "FF3B30")
    static let accentGold = UIColor(hex: "FFB800")
}

extension UILabel {
    static func make(text: String, font: UIFont, color: UIColor = .white) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        return label
    }
}

extension UIButton {
    static func makeText(text: String, color: UIColor, bg: UIColor = .clear) -> UIButton {
        // Исправление ошибки deprecated: Используем Configuration
        var config = UIButton.Configuration.filled()
        config.title = text
        config.baseForegroundColor = color
        config.baseBackgroundColor = bg
        config.cornerStyle = .fixed
        config.background.cornerRadius = 14
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        
        let button = UIButton(configuration: config)
        return button
    }
}
