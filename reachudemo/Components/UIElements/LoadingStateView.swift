import SwiftUI

/// Componente para mostrar un estado de carga
struct LoadingStateView: View {
    let message: String
    let showProgress: Bool
    
    init(message: String = "Cargando...", showProgress: Bool = true) {
        self.message = message
        self.showProgress = showProgress
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Padding.medium) {
            if showProgress {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(.bottom, AppTheme.Padding.medium)
            }
            
            Text(message)
                .font(.body)
                .foregroundColor(AppTheme.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding()
    }
}

/// Componente para mostrar un estado de error
struct ErrorStateView: View {
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(message: String, actionTitle: String? = "Reintentar", action: (() -> Void)? = nil) {
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Padding.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.warning)
                .padding(.bottom, AppTheme.Padding.small)
            
            Text(message)
                .font(.body)
                .foregroundColor(AppTheme.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.Padding.standard)
                        .padding(.vertical, AppTheme.Padding.small)
                        .background(AppTheme.primaryColor)
                        .cornerRadius(AppTheme.CornerRadius.standard)
                }
                .padding(.top, AppTheme.Padding.small)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding()
    }
}

/// Componente para mostrar estado de datos vacíos
struct EmptyStateView: View {
    let title: String
    let message: String
    let iconName: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        message: String,
        iconName: String = "tray",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.iconName = iconName
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Padding.standard) {
            Image(systemName: iconName)
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.tertiaryLabel)
                .padding(.bottom, AppTheme.Padding.small)
            
            Text(title)
                .font(.headline)
                .bold()
                .foregroundColor(AppTheme.Colors.label)
            
            Text(message)
                .font(.body)
                .foregroundColor(AppTheme.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.Padding.standard)
                        .padding(.vertical, AppTheme.Padding.medium)
                        .background(AppTheme.primaryColor)
                        .cornerRadius(AppTheme.CornerRadius.standard)
                }
                .padding(.top, AppTheme.Padding.medium)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 240)
        .padding()
    }
}

/// Vista que muestra automáticamente el estado correcto (cargando, error, vacío o contenido)
struct StateAwareView<Content: View>: View {
    let isLoading: Bool
    let error: Error?
    let isEmpty: Bool
    let emptyTitle: String
    let emptyMessage: String
    let emptyIconName: String
    let emptyAction: (() -> Void)?
    let retryAction: (() -> Void)?
    let content: () -> Content
    
    init(
        isLoading: Bool,
        error: Error? = nil,
        isEmpty: Bool = false,
        emptyTitle: String = "No hay datos",
        emptyMessage: String = "No se encontraron elementos para mostrar",
        emptyIconName: String = "tray",
        emptyAction: (() -> Void)? = nil,
        retryAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isLoading = isLoading
        self.error = error
        self.isEmpty = isEmpty
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.emptyIconName = emptyIconName
        self.emptyAction = emptyAction
        self.retryAction = retryAction
        self.content = content
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                LoadingStateView()
            } else if let error = error {
                ErrorStateView(
                    message: "Error: \(error.localizedDescription)",
                    action: retryAction
                )
            } else if isEmpty {
                EmptyStateView(
                    title: emptyTitle,
                    message: emptyMessage,
                    iconName: emptyIconName,
                    actionTitle: emptyAction != nil ? "Continuar" : nil,
                    action: emptyAction
                )
            } else {
                content()
            }
        }
    }
}

#Preview {
    Group {
        VStack(spacing: 20) {
            LoadingStateView()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(8)
            
            ErrorStateView(message: "No se pudo cargar los productos", action: {})
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(8)
            
            EmptyStateView(
                title: "Carrito Vacío",
                message: "Aún no has agregado productos a tu carrito",
                iconName: "cart",
                actionTitle: "Ir a Comprar",
                action: {}
            )
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(8)
            
            StateAwareView(
                isLoading: false,
                error: nil,
                isEmpty: true,
                emptyTitle: "Sin Favoritos",
                emptyMessage: "No has marcado ningún producto como favorito",
                emptyIconName: "heart",
                emptyAction: {},
                retryAction: {}
            ) {
                Text("Contenido normal")
            }
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(8)
        }
        .padding()
        .previewDisplayName("Light Mode")
        
        VStack(spacing: 20) {
            LoadingStateView()
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(8)
            
            ErrorStateView(message: "No se pudo cargar los productos", action: {})
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(8)
            
            EmptyStateView(
                title: "Carrito Vacío",
                message: "Aún no has agregado productos a tu carrito",
                iconName: "cart",
                actionTitle: "Ir a Comprar",
                action: {}
            )
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(8)
            
            StateAwareView(
                isLoading: false,
                error: nil,
                isEmpty: true,
                emptyTitle: "Sin Favoritos",
                emptyMessage: "No has marcado ningún producto como favorito",
                emptyIconName: "heart",
                emptyAction: {},
                retryAction: {}
            ) {
                Text("Contenido normal")
                    .foregroundColor(AppTheme.Colors.label)
            }
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(8)
        }
        .padding()
        .background(AppTheme.Colors.background)
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark Mode")
    }
} 