import UIKit

struct Theme {
    struct Colors {
        // Japanese Traditional Colors
        // 背景 (Background)
        static let background = UIColor(hex: "0A0A0A") // Sumi (墨) - Traditional ink black
        static let surface = UIColor(hex: "1A1A1A") // Charcoal gray
        static let surfaceSecondary = UIColor(hex: "2A2A2A") // Lighter charcoal
        
        // アクセント (Accents)
        static let primary = UIColor(hex: "DC143C") // Aka (赤) - Crimson red, traditional Japanese red
        static let secondary = UIColor(hex: "F5F5F5") // Shiro (白) - Rice paper white
        static let accent = UIColor(hex: "FFD700") // Kin (金) - Gold leaf
        
        // テキスト (Text)
        static let textPrimary = UIColor(hex: "FFFFFF") // White text on dark
        static let textSecondary = UIColor(hex: "CCCCCC") // Gray text
        static let textOnLight = UIColor(hex: "0A0A0A") // Black text on light
        
        // 機能的 (Functional)
        static let success = UIColor(hex: "4CAF50") // Green
        static let warning = UIColor(hex: "FF9800") // Amber
        static let error = UIColor(hex: "DC143C") // Use primary red for errors
    }
    
    struct Fonts {
        static func display(size: CGFloat) -> UIFont {
            .systemFont(ofSize: size, weight: .bold)
        }
        
        static func title(size: CGFloat) -> UIFont {
            .systemFont(ofSize: size, weight: .semibold)
        }
        
        static func body(size: CGFloat) -> UIFont {
            .systemFont(ofSize: size, weight: .regular)
        }
    }
    
    struct Spacing {
        // Ma (間) - Negative space principle
        static let xs: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    struct CornerRadius {
        // Japanese style - minimal rounding
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
    }
}
