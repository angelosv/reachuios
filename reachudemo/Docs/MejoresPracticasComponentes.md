# Guía de Mejores Prácticas para Componentes de E-commerce

## Principios de Diseño

1. **Consistencia**: Los componentes deben mantener consistencia visual y funcional en toda la aplicación.
2. **Reutilización**: Diseñar componentes para ser reutilizados en diferentes contextos.
3. **Composición**: Preferir la composición de componentes pequeños sobre componentes monolíticos.
4. **Separación de Responsabilidades**: Cada componente debe tener una responsabilidad única y clara.
5. **Personalización**: Los componentes deben ser personalizables pero con valores predeterminados sensatos.

## Estructura de Carpetas

```
reachudemo/
├── Components/
│   ├── UIElements/         # Componentes UI básicos (botones, campos, etc.)
│   ├── ProductCards/       # Variantes de tarjetas de producto
│   ├── Cart/               # Componentes relacionados con el carrito
│   └── Checkout/           # Componentes relacionados con el checkout
└── Views/                  # Pantallas completas
```

## Mejores Prácticas para Componentes

### 1. Diseño de Props

```swift
// ❌ MAL: Demasiadas propiedades independientes
struct ProductCard: View {
    let title: String
    let price: Double
    let imageURL: URL?
    let currencyCode: String
    let comparePrice: Double?
    let onTap: () -> Void
    // ...
}

// ✅ BIEN: Usar modelos existentes y closures para acciones
struct ProductCard: View {
    let product: Product
    let onTap: () -> Void
    let onAddToCart: () -> Void
}
```

### 2. Estilos Coherentes

Centralizar estilos en un archivo de tema (AppTheme) y utilizarlos en todos los componentes para garantizar coherencia visual.

```swift
// ❌ MAL: Valores hardcodeados en cada componente
Text("Precio")
    .font(.system(size: 15, weight: .bold))
    .foregroundColor(Color(hex: "#7300f9"))

// ✅ BIEN: Usar estilos centralizados
Text("Precio")
    .font(AppTheme.TextStyle.price)
    .foregroundColor(AppTheme.primaryColor)
```

### 3. Componentes para Estados

Crear componentes específicos para manejar diferentes estados de la interfaz:

- `LoadingStateView` para estados de carga
- `ErrorStateView` para mostrar errores
- `EmptyStateView` para estados vacíos

### 4. Composición vs. Herencia

En SwiftUI, prefiere la composición de componentes sobre enfoques basados en herencia:

```swift
// ✅ BIEN: Componentes componibles
struct ProductInfo: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(product.title)
                .font(AppTheme.TextStyle.bodyBold)
            
            PriceView(from: product.price)
        }
    }
}

struct ProductCard: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            RemoteImage(url: product.mainImageURL)
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
            
            ProductInfo(product: product)
            
            // Botones y otras acciones...
        }
        .onTapGesture(perform: onTap)
    }
}
```

### 5. Componentes Paramétricos

Preferir componentes con parámetros opcionales y valores predeterminados en lugar de múltiples variantes similares:

```swift
// ❌ MAL: Múltiples componentes similares
struct SmallProductCard: View { /* ... */ }
struct LargeProductCard: View { /* ... */ }
struct FeaturedProductCard: View { /* ... */ }

// ✅ BIEN: Un componente paramétrico
struct ProductCard: View {
    enum Size { case small, medium, large }
    enum Style { case standard, featured, minimal }
    
    let product: Product
    let size: Size
    let style: Style
    let onTap: () -> Void
    
    init(product: Product, 
         size: Size = .medium,
         style: Style = .standard,
         onTap: @escaping () -> Void) {
        self.product = product
        self.size = size
        self.style = style
        self.onTap = onTap
    }
    
    var body: some View {
        // Implementación que varía según size y style
    }
}
```

## Reutilización entre Vistas

Para facilitar la reutilización de componentes entre diferentes vistas:

1. **Componentes Independientes**: Diseñar componentes que no dependan de ViewModels específicos, sino que reciban datos e interacciones a través de propiedades y closures.

2. **Inyección de Dependencias**: Pasar las dependencias (modelos, closures) desde la vista principal en lugar de crear dependencias dentro de los componentes.

```swift
// ❌ MAL: Dependencia directa del ViewModel
struct ProductList: View {
    @StateObject private var viewModel = StoreViewModel()
    
    var body: some View {
        // ...
    }
}

// ✅ BIEN: Recibir modelo como parámetro
struct ProductList: View {
    @ObservedObject var viewModel: StoreViewModel
    
    var body: some View {
        // ...
    }
}
```

3. **Patrón Contenedor/Presentación**: Separar los componentes "inteligentes" (con lógica) de los componentes "tontos" (puramente presentacionales).

```swift
// Componente presentacional (tonto)
struct ProductGridItem: View {
    let product: Product
    let onTap: () -> Void
    let onAddToCart: () -> Void
    
    var body: some View {
        // Sólo presentación, sin lógica de negocio
    }
}

// Componente contenedor (inteligente)
struct ProductGrid: View {
    @ObservedObject var viewModel: StoreViewModel
    
    var body: some View {
        LazyVGrid(columns: /*...*/) {
            ForEach(viewModel.products) { product in
                ProductGridItem(
                    product: product,
                    onTap: { viewModel.selectProduct(product) },
                    onAddToCart: { viewModel.addToCart(product) }
                )
            }
        }
    }
}
```

## Recomendaciones para el Rendimiento

1. **Lazy Loading**: Utilizar `LazyVStack`, `LazyHStack` y `LazyVGrid` para rendimiento con grandes colecciones.

2. **Tamaños Fijos**: Cuando sea posible, usar tamaños fijos para reducir recálculos de layout.

3. **Identifiers Estables**: Usar identificadores estables para ForEach y List.

4. **Cachear Valores Computados**: Para valores computados costosos, considerar cachearlos en propiedades.

5. **Evitar Anidamiento Excesivo**: Limitar el anidamiento excesivo de vistas para mejor rendimiento.

## Ejemplo de Implementación

Ver los archivos:
- `AppTheme.swift`: Tema centralizado
- `ActionButton.swift`: Botón reutilizable con múltiples estilos
- `PriceView.swift`: Componente para mostrar precios
- `LoadingStateView.swift`: Componentes para manejar estados
- `StoreViewRefactored.swift`: Ejemplo de uso de componentes 