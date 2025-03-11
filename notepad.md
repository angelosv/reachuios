# Reachu Demo App - Estructura y Componentes

## Estructura del Proyecto
```
reachudemo/
├── Models/
│   └── Article.swift (modelo para artículos con categorías)
├── Views/
│   ├── HomeView.swift (vista principal con artículos y categorías)
│   ├── LivestreamView.swift (vista de transmisiones en vivo)
│   └── MainTabView.swift (navegación principal con tabs)
├── ViewModels/
│   ├── ArticleViewModel.swift (lógica para artículos)
│   └── LivestreamViewModel.swift (lógica para livestreams)
├── Components/
│   ├── FeaturedArticlesView.swift (carrusel de artículos destacados)
│   ├── CategoryCard.swift (tarjeta de categoría)
│   └── TrendingArticleRow.swift (fila de artículo en tendencia)
├── Services/
│   ├── NetworkService.swift (manejo de peticiones HTTP)
│   ├── ReachuService.swift (integración con Reachu.io GraphQL)
│   └── LivestreamService.swift (integración con API de livestream)
└── Utils/
    └── DateFormatters.swift (utilidades para formato de fechas)

## Componentes Implementados

### Vistas Principales
1. HomeView
   - Carrusel de artículos destacados
   - Sección de categorías horizontal
   - Lista de artículos en tendencia
   - Barra de navegación con título "Eksplor" y botón de búsqueda

2. LivestreamView
   - Lista de transmisiones en vivo
   - Indicador de estado en vivo
   - Contador de espectadores
   - Categorías de transmisión

3. MainTabView
   - Tab "Home" con HomeView
   - Tab "Live" con LivestreamView
   - Tab "Profile" (pendiente de implementar)

### Modelos de Datos
1. Article
   - Propiedades: id, title, subtitle, content, imageName, etc.
   - Categorías: Diet, Diabetic Lifestyle, Daily Nutrition, General

2. Livestream
   - Propiedades: id, title, description, thumbnailURL, hostName, etc.
   - Estado en vivo y contador de espectadores

### Servicios
1. NetworkService
   - Manejo genérico de peticiones HTTP
   - Manejo de errores y respuestas

2. ReachuService
   - Integración con GraphQL
   - Queries para artículos y categorías

3. LivestreamService
   - Manejo de transmisiones en vivo
   - Conexión y estado de transmisiones

## Estado Actual
- ✅ Estructura base implementada
- ✅ Navegación principal funcionando
- ✅ Diseño de UI siguiendo guías de Apple
- ✅ Componentes reutilizables creados
- ✅ Servicios base implementados

## Pendiente
- Implementar vista de Perfil
- Integrar APIs reales (actualmente usando datos de ejemplo)
- Implementar búsqueda
- Añadir autenticación de usuario
- Implementar caché y modo offline

## Notas Técnicas
- Usando SwiftUI para la UI
- MVVM como patrón de arquitectura
- Combine para manejo de datos reactivos
- Target iOS 15.0+ 