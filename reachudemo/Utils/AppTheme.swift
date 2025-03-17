import SwiftUI

/// Tema centralizado de la aplicación para mantener consistencia visual
struct AppTheme {
    // MARK: - Colores
    static let primaryColor = Color(hex: "#7300f9")
    static let secondaryColor = Color(hex: "#fd5d4e")
    
    // MARK: - Colores adaptables a modo oscuro
    struct Colors {
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
        
        static let label = Color(UIColor.label)
        static let secondaryLabel = Color(UIColor.secondaryLabel)
        static let tertiaryLabel = Color(UIColor.tertiaryLabel)
        
        static let separator = Color(UIColor.separator)
        static let opaqueSeparator = Color(UIColor.opaqueSeparator)
        
        static let groupedBackground = Color(UIColor.systemGroupedBackground)
        static let card = Color(UIColor.secondarySystemGroupedBackground)
        
        static let fill = Color(UIColor.systemFill)
        static let secondaryFill = Color(UIColor.secondarySystemFill)
        static let tertiaryFill = Color(UIColor.tertiarySystemFill)
        static let quaternaryFill = Color(UIColor.quaternarySystemFill)
        
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
    }
    
    // MARK: - Dimensiones
    struct Padding {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let standard: CGFloat = 16
        static let large: CGFloat = 24
    }
    
    struct CornerRadius {
        static let small: CGFloat = 4
        static let standard: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    // MARK: - Estilos de Texto
    struct TextStyle {
        // Títulos
        static let title = Font.title.weight(.bold)
        static let subtitle = Font.title2.weight(.semibold)
        static let sectionHeader = Font.headline.weight(.bold)
        
        // Contenido
        static let bodyBold = Font.body.weight(.semibold)
        static let body = Font.body
        static let caption = Font.caption
        
        // Precios
        static let price = Font.system(size: 15, weight: .bold)
        static let comparePrice = Font.caption.weight(.regular)
    }
    
    // MARK: - Shadows
    static let standardShadow: Shadow = Shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
}

// Extensión para facilitar la creación de sombras
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func apply<T: View>(to view: T) -> some View {
        return view.shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - Extensión para Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 