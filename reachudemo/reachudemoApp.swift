//
//  reachudemoApp.swift
//  reachudemo
//
//  Created by Angelo Sepulveda on 10/03/2025.
//

import SwiftUI

@main
struct reachudemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
