#!/bin/bash

# Asegurarse de que estamos en el directorio correcto
cd "$(dirname "$0")"
cd ../..

# Verificar que el esquema existe
if [ ! -f "reachudemo/Apollo/graphql/schema.graphqls" ]; then
  echo "Error: El esquema GraphQL no existe."
  echo "Primero debes descargar el esquema con:"
  echo "rover graph introspect https://graph-ql.reachu.io/ --header \"Authorization: ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R\" > reachudemo/Apollo/graphql/schema.graphqls"
  exit 1
fi

# Verificar que el archivo de configuración existe
if [ ! -f "reachudemo/Apollo/apollo-codegen-config.json" ]; then
  echo "Error: El archivo de configuración apollo-codegen-config.json no existe."
  exit 1
fi

# Crear directorio para el código generado si no existe
mkdir -p reachudemo/Apollo/ApolloCodegen

# Generar código Swift usando Apollo CLI
echo "Generando código Swift a partir de las consultas GraphQL..."
apollo client:codegen --config=reachudemo/Apollo/apollo-codegen-config.json

echo "Código generado con éxito en reachudemo/Apollo/ApolloCodegen" 