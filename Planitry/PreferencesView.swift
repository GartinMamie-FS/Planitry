//
//  PreferencesView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI

// MARK: - Preferences View (A3)

// The Preferences View handles all user inputs for dietary and health constraints.
struct PreferencesView: View {
    // Access the shared settings object
    @ObservedObject var settings: UserSettings
    
    // Convert the comma-separated string back to a Set for easy management in the UI
    @State private var activeConstraints: Set<String> = {
        // We create a temporary instance here to safely read the initial AppStorage value
        let constraints = UserSettings().activeHealthConstraintsString.split(separator: ",")
        return Set(constraints.map { String($0) })
    }()
    
    var body: some View {
        NavigationView {
            Form {
                // Section 1: Dietary Label
                Section(header: Text("Dietary Preference (Required)")) {
                    Picker("Select Diet", selection: $settings.selectedDiet) {
                        ForEach(["Low-Fat", "Low-Carb", "Keto", "Vegan", "Vegetarian", "Pescatarian"], id: \.self) { diet in
                            Text(diet)
                        }
                    }
                }
                
                // Section 2: Calorie Budget
                Section(header: Text("Maximum Calories (Required)")) {
                    
                    // Stepper for better UX and keyboard avoidance.
                    Stepper(value: $settings.maxCalories, in: 100...5000, step: 100) {
                        HStack {
                            Text("Max Calories:")
                            Spacer()
                            // Display the current value
                            Text("\(settings.maxCalories) kcal")
                                .foregroundColor(.red)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                // Section 3: Health Constraints
                Section(header: Text("Health Constraints (Optional)")) {
                    // Iterate through all possible constraints and create a toggle for each
                    ForEach(HealthConstraint.allCases) { constraint in
                        Toggle(constraint.rawValue, isOn: binding(for: constraint.rawValue))
                    }
                }
            }
            .navigationTitle("Meal Preferences")
            .onChange(of: activeConstraints) { newConstraints in
                // When the local set changes, save it back to the persistence string
                settings.activeHealthConstraintsString = newConstraints.joined(separator: ",")
            }
        }
    }
    
    // Helper function to create a binding for each Toggle based on the 'activeConstraints' Set
    func binding(for constraint: String) -> Binding<Bool> {
        return Binding(
            get: { self.activeConstraints.contains(constraint) },
            set: { isEnabled in
                if isEnabled {
                    self.activeConstraints.insert(constraint)
                } else {
                    self.activeConstraints.remove(constraint)
                }
            }
        )
    }
}
