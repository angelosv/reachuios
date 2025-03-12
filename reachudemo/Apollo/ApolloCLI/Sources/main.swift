// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ApolloCodegenLib

// Función principal asíncrona
@main
struct ApolloCodegenScript {
    static func main() async {
        // Obtener la ruta del directorio actual
        let currentDirectory = FileManager.default.currentDirectoryPath
        let rootDirectory = currentDirectory.components(separatedBy: "reachudemo/Apollo/ApolloCLI")[0]
        let configPath = "\(rootDirectory)reachudemo/Apollo/apollo-codegen-config.json"

        print("Generando código Swift a partir de las consultas GraphQL...")
        print("Usando archivo de configuración: \(configPath)")

        // Verificar que el archivo de configuración existe
        guard FileManager.default.fileExists(atPath: configPath) else {
            print("Error: El archivo de configuración no existe en \(configPath)")
            exit(1)
        }

        // Verificar que el esquema existe
        let schemaPath = "\(rootDirectory)reachudemo/Apollo/graphql/schema.graphqls"
        guard FileManager.default.fileExists(atPath: schemaPath) else {
            print("Error: El esquema GraphQL no existe en \(schemaPath)")
            print("Primero debes descargar el esquema con:")
            print("rover graph introspect https://graph-ql.reachu.io/ --header \"Authorization: ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R\" > reachudemo/Apollo/graphql/schema.graphqls")
            exit(1)
        }

        do {
            // Crear una configuración básica manualmente
            let input = ApolloCodegenConfiguration.FileInput(
                schemaSearchPaths: ["\(rootDirectory)reachudemo/Apollo/graphql/schema.graphqls"],
                operationSearchPaths: ["\(rootDirectory)reachudemo/Apollo/graphql/**/*.graphql"]
            )
            
            let output = ApolloCodegenConfiguration.FileOutput(
                schemaTypes: .init(
                    path: "\(rootDirectory)reachudemo/Apollo/ApolloCodegen/Sources",
                    moduleType: .swiftPackageManager
                ),
                operations: .inSchemaModule,
                testMocks: .none
            )
            
            let configuration = ApolloCodegenConfiguration(
                schemaNamespace: "ReachuAPI",
                input: input,
                output: output
            )
            
            // Ejecutar la generación de código de forma asíncrona
            try await ApolloCodegen.build(with: configuration)
            
            print("✅ Código generado con éxito")
        } catch {
            print("❌ Error al generar el código: \(error)")
            exit(1)
        }
    }
}
