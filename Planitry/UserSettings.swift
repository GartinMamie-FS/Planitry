//
//  UserSettings.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/25/25.
//
import SwiftUI
import Combine

class UserSettings: ObservableObject {
    
    // Tracks if the user has completed the initial setup flow.
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    // Used to signal when the object is ready
    @Published var isInitialized: Bool = true
    
    // Diet Label
    @AppStorage("selectedDiet") var selectedDiet: String = "balanced"
    
    // Max Calorie Budget
    @AppStorage("maxCalories") var maxCalories: Int = 2000
    
    // Health Constraints stored as a comma-separated string
    @AppStorage("activeHealthConstraints") var activeHealthConstraintsString: String = ""
    
    /// COMPUTED PROPERTY: Safely convert the stored comma-separated string back to an array of strings.
    var activeHealthConstraints: [String] {
        return activeHealthConstraintsString
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    /// Clears the stored health constraints string.
    func resetHealthConstraints() {
        activeHealthConstraintsString = ""
        objectWillChange.send()
    }
    
    /// Sets all preferences back to their initial default state.
    func applyDefaultPreferences() {
        self.selectedDiet = "balanced"
        self.maxCalories = 2000
        self.activeHealthConstraintsString = ""
        self.hasCompletedOnboarding = true // Mark onboarding as complete upon setting defaults
    }
}
