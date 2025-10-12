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
    
    // Diet Label
    @AppStorage("selectedDiet") var selectedDiet: String = "balanced"
    
    // Max Calorie Budget
    @AppStorage("maxCalories") var maxCalories: Int = 2000
    
    // Health Constraints
    @AppStorage("activeHealthConstraints") var activeHealthConstraintsString: String = ""
    
    /// COMPUTED PROPERTY: Safely convert the stored comma-separated string back to an array of strings.
    var activeHealthConstraints: [String] {
        return activeHealthConstraintsString
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    func resetHealthConstraints() {
        activeHealthConstraintsString = ""
        objectWillChange.send()
    }
}

//MARK: - 2. Main Application Entry Point (A1)

// The Main Application Entry Point, containing the TabView navigation.
struct ContentView: View {
    @StateObject var settings = UserSettings()
    
    var body: some View {
        TabView {
            // Tab 1: Planner
            PlannerView(settings: settings)
                .tabItem {
                    Label("Planner", systemImage: "fork.knife")
                }
            
            // Tab 2: Preferences
            PreferencesView(settings: settings)
                .tabItem {
                    Label("Preferences", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.red)
    }
}
