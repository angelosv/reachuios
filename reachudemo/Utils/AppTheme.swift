import SwiftUI

/// Tema centralizado de la aplicación para mantener consistencia visual
struct AppTheme {
    // MARK: - Colores
    static let primaryColor = Color(hex: "#7300f9")
    static let secondaryColor = Color(hex: "#fd5d4e")
    static let backgroundColor = Color(UIColor.systemBackground)
    static let cardBackgroundColor = Color(UIColor.secondarySystemBackground)
    
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