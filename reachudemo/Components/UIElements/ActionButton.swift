import SwiftUI

/// Estilos predefinidos para botones
enum ActionButtonStyle: Equatable {
    case primary
    case secondary
    case outline
    case ghost
    case destructive
    case icon(systemName: String)
    
    // Obtener color de fondo basado en el estilo
    var backgroundColor: Color {
        switch self {
        case .primary:
            return AppTheme.primaryColor
        case .secondary:
            return AppTheme.secondaryColor
        case .outline, .ghost:
            return .clear
        case .destructive:
            return Color.red
        case .icon:
            return AppTheme.primaryColor
        }
    }
    
    // Obtener color de texto basado en el estilo
    var foregroundColor: Color {
        switch self {
        case .primary, .secondary, .destructive, .icon:
            return .white
        case .outline:
            return AppTheme.primaryColor
        case .ghost:
            return AppTheme.Colors.label
        }
    }
    
    // Obtener color de borde basado en el estilo
    var borderColor: Color? {
        switch self {
        case .outline:
            return AppTheme.primaryColor
        default:
            return nil
        }
    }
}

/// Tamaños predefinidos para botones
enum ActionButtonSize {
    case small
    case medium
    case large
    case custom(height: CGFloat, horizontalPadding: CGFloat)
    
    var height: CGFloat {
        switch self {
        case .small:
            return 32
        case .medium:
            return 44
        case .large:
            return 54
        case .custom(let height, _):
            return height
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return 12
        case .medium:
            return 16
        case .large:
            return 20
        case .custom(_, let padding):
            return padding
        }
    }
    
    var font: Font {
        switch self {
        case .small:
            return .subheadline
        case .medium:
            return .body
        case .large:
            return .title3
        case .custom:
            return .body
        }
    }
}

/// Botón de acción reutilizable con estilos personalizables
struct ActionButton: View {
    let title: String
    let style: ActionButtonStyle
    let size: ActionButtonSize
    let isFullWidth: Bool
    let cornerRadius: CGFloat
    let action: () -> Void
    
    init(
        title: String,
        style: ActionButtonStyle = .primary,
        size: ActionButtonSize = .medium,
        isFullWidth: Bool = false,
        cornerRadius: CGFloat = AppTheme.CornerRadius.standard,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isFullWidth = isFullWidth
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            buttonContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        switch style {
        case .icon(let systemName):
            iconButtonView(systemName: systemName)
        default:
            textButtonView
        }
    }
    
    private var textButtonView: some View {
        Text(title)
            .font(size.font.weight(.semibold))
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: isFullWidth ? .infinity : nil, minHeight: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(style.backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(style.borderColor ?? .clear, lineWidth: style == .outline ? 1.5 : 0)
            )
    }
    
    private func iconButtonView(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(style.foregroundColor)
            .frame(width: size.height, height: size.height)
            .background(style.backgroundColor)
            .cornerRadius(size.height / 2)
    }
}

// Versión simplificada para botones con íconos (p.ej. botón de agregar al carrito)
extension ActionButton {
    static func iconButton(
        systemName: String,
        backgroundColor: Color = AppTheme.primaryColor,
        foregroundColor: Color = .white,
        size: CGFloat = 32,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    Group {
        VStack(spacing: 20) {
            ActionButton(title: "Comprar ahora", style: .primary, size: .large, isFullWidth: true) {}
            ActionButton(title: "Agregar al carrito", style: .secondary) {}
            ActionButton(title: "Ver detalles", style: .outline) {}
            ActionButton(title: "Cancelar", style: .ghost) {}
            ActionButton(title: "Eliminar", style: .destructive, size: .small) {}
            ActionButton(title: "", style: .icon(systemName: "plus")) {}
            ActionButton.iconButton(systemName: "cart.badge.plus") {}
        }
        .padding()
        .previewDisplayName("Light Mode")
        
        VStack(spacing: 20) {
            ActionButton(title: "Comprar ahora", style: .primary, size: .large, isFullWidth: true) {}
            ActionButton(title: "Agregar al carrito", style: .secondary) {}
            ActionButton(title: "Ver detalles", style: .outline) {}
            ActionButton(title: "Cancelar", style: .ghost) {}
            ActionButton(title: "Eliminar", style: .destructive, size: .small) {}
            ActionButton(title: "", style: .icon(systemName: "plus")) {}
            ActionButton.iconButton(systemName: "cart.badge.plus") {}
        }
        .padding()
        .background(AppTheme.Colors.background)
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark Mode")
    }
} 