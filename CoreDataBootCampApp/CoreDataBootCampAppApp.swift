//
//  CoreDataBootCampAppApp.swift
//  CoreDataBootCampApp
//
//  Created by Rajesh Mani on 24/10/23.
//

import SwiftUI

@main
struct CoreDataBootCampAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
