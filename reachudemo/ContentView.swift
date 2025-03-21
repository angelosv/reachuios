//
//  ContentView.swift
//  reachudemo
//
//  Created by Angelo Sepulveda on 10/03/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showGraphQLExplorer = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)

                // Añadir sección de herramientas para desarrolladores
                Section(header: Text("Herramientas de desarrollo")) {
                    Button(action: {
                        showGraphQLExplorer = true
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass.circle")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Explorador de Schema GraphQL")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .overlay(debugButton())
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Reachu Demo")
            .sheet(isPresented: $showGraphQLExplorer) {
                SchemaExplorerView()
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Debugging Tools
extension ContentView {
    @ViewBuilder
    func debugButton() -> some View {
        #if DEBUG
        VStack {
            Spacer()
            HStack {
                Spacer()
                Menu {
                    Button(action: {
                        showGraphQLExplorer = true
                    }) {
                        Label("Explorador GraphQL", systemImage: "magnifyingglass")
                    }
                    // Otros elementos de debug si los necesitas
                } label: {
                    Image(systemName: "ladybug.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showGraphQLExplorer) {
            SchemaExplorerView()
        }
        #else
        EmptyView()
        #endif
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
