//
//  ContentView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI
import Combine



// MARK: - 1. Persistence Layer (A2)

class UserSettings: ObservableObject {
    
    @Published var isInitialized: Bool = true

    // Diet Label (e.g., "Keto", "Vegan")
    @AppStorage("selectedDiet") var selectedDiet: String = "Low-Fat"
    
    // Max Calorie Budget (e.g., 2000)
    @AppStorage("maxCalories") var maxCalories: Int = 2000
    
    // Health Constraints
    @AppStorage("activeHealthConstraints") var activeHealthConstraintsString: String = ""
}


//MARK: - 2. Main Application Entry Point (A1)

// The Main Application Entry Point, containing the TabView navigation.
struct ContentView: View {
    // Inject the persistence class globally. This is the SINGLE SOURCE OF TRUTH.
    @StateObject var settings = UserSettings()
    
    var body: some View {
        TabView {
            // Tab 1: Planner
            // UPDATED: Now passing the settings object to PlannerView
            PlannerView(settings: settings)
                .tabItem {
                    Label("Planner", systemImage: "fork.knife")
                }
            
            // Tab 2: Preferences (already correct)
            PreferencesView(settings: settings)
                .tabItem {
                    Label("Preferences", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.red)
    }
}

