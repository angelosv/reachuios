# Apollo GraphQL Integration for Reachu iOS

Este directorio contiene una implementación aislada de Apollo GraphQL para la aplicación Reachu iOS. La estructura está diseñada para permitir experimentar con Apollo GraphQL sin afectar la funcionalidad existente de la aplicación.

## Estructura de archivos

- `ApolloManager.swift`: Gestiona la conexión con el servidor GraphQL y proporciona métodos para realizar consultas.
- `ApolloModels.swift`: Define los modelos de datos utilizados por Apollo GraphQL.
- `ApolloViewModel.swift`: Implementa la lógica de negocio para interactuar con los datos de GraphQL.
- `ApolloExampleView.swift`: Muestra un ejemplo de cómo utilizar Apollo GraphQL en una vista SwiftUI.
- `ApolloProductCard.swift`: Componente reutilizable para mostrar productos.
- `ApolloExtensions.swift`: Extensiones útiles para la implementación de Apollo.

## Integración con Swift Package Manager

Para integrar completamente Apollo GraphQL, sigue estos pasos:

1. Abre el proyecto en Xcode
2. Selecciona File > Swift Packages > Add Package Dependency
3. Ingresa la URL del repositorio de Apollo iOS: `https://github.com/apollographql/apollo-ios.git`
4. Selecciona la versión más reciente (recomendado: 1.0.0 o superior)
5. Añade el paquete al target principal de la aplicación

## Actualización del código

Una vez que hayas añadido el paquete, necesitarás actualizar `ApolloManager.swift` para utilizar el cliente Apollo oficial en lugar de la implementación temporal basada en URLSession.

```swift
import Apollo

class ApolloManager {
    static let shared = ApolloManager()
    
    private(set) lazy var client: ApolloClient = {
        let url = URL(string: "https://tu-endpoint-graphql.com/graphql")!
        let store = ApolloStore()
        let provider = NetworkInterceptorProvider(store: store)
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: url
        )
        return ApolloClient(networkTransport: transport, store: store)
    }()
    
    // Implementa los métodos necesarios para utilizar el cliente Apollo
}

// Implementa el proveedor de interceptores para manejar la autenticación
private class NetworkInterceptorProvider: InterceptorProvider {
    // Implementación del proveedor de interceptores
}
```

## Ejemplo de uso

```swift
// En tu ViewModel
func fetchProducts() {
    let query = ProductsQuery()
    ApolloManager.shared.client.fetch(query: query) { result in
        switch result {
        case .success(let graphQLResult):
            if let products = graphQLResult.data?.products {
                // Procesa los productos
            }
        case .failure(let error):
            // Maneja el error
        }
    }
}
```

## Notas importantes

- Esta implementación está aislada del resto de la aplicación para permitir experimentación.
- Para una integración completa, se recomienda refactorizar gradualmente los servicios existentes.
- Asegúrate de probar exhaustivamente antes de reemplazar la implementación actual. 