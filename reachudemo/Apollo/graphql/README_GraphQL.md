# Apollo GraphQL para Reachu iOS

Este directorio contiene el esquema GraphQL y las consultas para la aplicación Reachu iOS.

## Estructura de archivos

- `schema.graphqls`: El esquema GraphQL descargado del servidor.
- `queries/`: Directorio que contiene todas las consultas GraphQL.
  - `GetProducts.graphql`: Consulta para obtener productos.
  - `GetProductDetail.graphql`: Consulta para obtener detalles de un producto específico.
  - `SearchProducts.graphql`: Consulta para buscar productos.

## Cómo actualizar el esquema

Si el esquema GraphQL del servidor cambia, puedes actualizarlo con el siguiente comando:

```bash
rover graph introspect https://graph-ql.reachu.io/ --header "Authorization: ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R" > schema.graphqls
```

## Cómo añadir nuevas consultas

1. Crea un nuevo archivo `.graphql` en el directorio `queries/`.
2. Define tu consulta GraphQL en el archivo.
3. Ejecuta el script de generación de código para actualizar el código Swift.

## Cómo generar código Swift

Después de actualizar el esquema o añadir nuevas consultas, debes generar el código Swift correspondiente:

1. Asegúrate de tener instalado Apollo CLI:
   ```bash
   npm install -g apollo
   ```

2. Ejecuta el script de generación de código desde la raíz del proyecto:
   ```bash
   ./reachudemo/Apollo/generate-apollo-code.sh
   ```

3. El código generado se guardará en `reachudemo/Apollo/ApolloCodegen/`.

## Uso con Apollo Client

Una vez generado el código, puedes usar las consultas con Apollo Client:

```swift
import Apollo
import ReachuAPI // Módulo generado

// Ejemplo de uso
let apolloClient = ApolloClient(...)
let query = GetProductsQuery(limit: 20, offset: 0)

apolloClient.fetch(query: query, cachePolicy: .returnCacheDataElseFetch) { result in
    switch result {
    case .success(let graphQLResult):
        if let products = graphQLResult.data?.channel?.getProducts {
            // Procesar productos
        }
    case .failure(let error):
        // Manejar error
    }
}
```

## Políticas de caché disponibles

Apollo Client ofrece varias políticas de caché:

- `.returnCacheDataElseFetch`: Usa caché si está disponible, sino hace fetch.
- `.returnCacheDataAndFetch`: Usa caché inmediatamente y actualiza en segundo plano.
- `.returnCacheDataDontFetch`: Solo usa caché, no hace fetch.
- `.fetchIgnoringCacheData`: Ignora caché, hace fetch y actualiza caché.
- `.fetchIgnoringCacheCompletely`: Ignora caché completamente. 