//
//  Plot_CalcApp.swift
//  Plot Calc
//
//  Created by Filip Dabkowski on 07/04/2021.
//

import SwiftUI

@main
struct Plot_CalcApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
