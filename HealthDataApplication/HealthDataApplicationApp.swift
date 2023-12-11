//
//  HealthDataApplicationApp.swift
//  HealthDataApplication
//
//  Created by User on 08.12.2023.
//

import SwiftUI

@main
struct HealthDataApplicationApp: App {
    @StateObject private var healthStore = HealthStore()
    var body: some Scene {
        WindowGroup {
            if healthStore.isAuthorised {
                HealthInsightsView()
                    .environmentObject(healthStore)
            } else {
                WelcomeView()
                    .environmentObject(healthStore)
            }
        }
    }
}
