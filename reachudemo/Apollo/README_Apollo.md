# Integración de Apollo GraphQL en Reachu iOS

Este directorio contiene la implementación de Apollo GraphQL para la aplicación Reachu iOS.

## Estructura de archivos

- `apollo-codegen-config.json`: Configuración para la generación de código Swift a partir de consultas GraphQL.
- `generate-apollo-code.sh`: Script para generar código Swift a partir de consultas GraphQL.
- `ApolloClient.swift`: Cliente Apollo básico para realizar consultas GraphQL.
- `ApolloCacheClient.swift`: Cliente Apollo con sistema de caché para realizar consultas GraphQL.
- `ApolloProductsViewModel.swift`: ViewModel básico para productos de Apollo.
- `ApolloCacheViewModel.swift`: ViewModel con sistema de caché para productos de Apollo.
- `ApolloProductsView.swift`: Vista de ejemplo para mostrar productos de Apollo.
- `ApolloCacheExampleView.swift`: Vista de ejemplo para mostrar productos de Apollo con caché.
- `graphql/`: Directorio con el esquema GraphQL y las consultas.
  - `schema.graphqls`: Esquema GraphQL.
  - `queries/`: Directorio con las consultas GraphQL.
    - `GetProducts.graphql`: Consulta para obtener productos.
    - `GetProductDetail.graphql`: Consulta para obtener detalles de un producto.
    - `SearchProducts.graphql`: Consulta para buscar productos.
- `ApolloCodegen/`: Directorio con el código Swift generado a partir de las consultas GraphQL.

## Actualización del esquema GraphQL

Para actualizar el esquema GraphQL, ejecuta el siguiente comando:

```bash
rover graph introspect https://graph-ql.reachu.io/ --header "Authorization: ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R" > reachudemo/Apollo/graphql/schema.graphqls
```

## Agregar nuevas consultas

Para agregar nuevas consultas, crea un archivo `.graphql` en el directorio `graphql/queries/` con la consulta GraphQL.

## Generar código Swift

Para generar código Swift a partir de las consultas GraphQL, ejecuta el siguiente comando:

```bash
./reachudemo/Apollo/generate-apollo-code.sh
```

## Uso del cliente Apollo básico

```swift
import ReachuAPI

// Obtener productos
ApolloClient.shared.fetchProducts { result in
    switch result {
    case .success(let products):
        print("Productos: \(products)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Obtener detalles de un producto
ApolloClient.shared.fetchProduct(id: 123) { result in
    switch result {
    case .success(let product):
        print("Producto: \(product)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Buscar productos
ApolloClient.shared.searchProducts { result in
    switch result {
    case .success(let products):
        print("Productos: \(products)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

## Uso del cliente Apollo con caché

```swift
import ReachuAPI
import Apollo

// Obtener productos con política de caché
ApolloCacheClient.shared.fetchProducts(cachePolicy: .returnCacheDataElseFetch) { result in
    switch result {
    case .success(let products):
        print("Productos: \(products)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Obtener detalles de un producto con política de caché
ApolloCacheClient.shared.fetchProduct(id: 123, cachePolicy: .returnCacheDataElseFetch) { result in
    switch result {
    case .success(let product):
        print("Producto: \(product)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Buscar productos con política de caché
ApolloCacheClient.shared.searchProducts(cachePolicy: .returnCacheDataElseFetch) { result in
    switch result {
    case .success(let products):
        print("Productos: \(products)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Limpiar la caché
ApolloCacheClient.shared.clearCache { result in
    switch result {
    case .success:
        print("Caché limpiada con éxito")
    case .failure(let error):
        print("Error al limpiar la caché: \(error)")
    }
}
```

## Uso del ViewModel básico

```swift
import SwiftUI

struct ProductsView: View {
    @StateObject private var viewModel = ApolloProductsViewModel()
    
    var body: some View {
        List(viewModel.products, id: \.id) { product in
            Text(product.title)
        }
        .onAppear {
            viewModel.fetchProducts()
        }
    }
}
```

## Uso del ViewModel con caché

```swift
import SwiftUI
import Apollo

struct ProductsView: View {
    @StateObject private var viewModel = ApolloCacheViewModel()
    
    var body: some View {
        List(viewModel.products, id: \.id) { product in
            Text(product.title)
        }
        .onAppear {
            viewModel.fetchProducts(cachePolicy: .returnCacheDataElseFetch)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Limpiar caché") {
                    viewModel.clearCache()
                }
            }
        }
    }
}
```

## Políticas de caché

Apollo iOS proporciona varias políticas de caché para controlar cómo se cargan los datos:

- `.returnCacheDataElseFetch`: Devuelve los datos de la caché si están disponibles, de lo contrario, realiza una solicitud de red.
- `.fetchIgnoringCacheData`: Siempre realiza una solicitud de red y actualiza la caché con el resultado.
- `.fetchIgnoringCacheCompletely`: Siempre realiza una solicitud de red y no actualiza la caché.
- `.returnCacheDataDontFetch`: Devuelve los datos de la caché si están disponibles, de lo contrario, devuelve un error.
- `.returnCacheDataAndFetch`: Devuelve los datos de la caché si están disponibles y luego realiza una solicitud de red para actualizar la caché.

Para usar una política de caché específica, pasa el parámetro `cachePolicy` al método `fetch`:

```swift
apollo.fetch(query: GetProductsQuery(), cachePolicy: .fetchIgnoringCacheData) { result in
    // ...
}
``` 