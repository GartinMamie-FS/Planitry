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
    
    @State private var activeConstraints: Set<String>
    
    init(settings: UserSettings) {
        self._settings = ObservedObject(wrappedValue: settings)
        
        _activeConstraints = State(initialValue: Set(settings.activeHealthConstraints))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Section 1: Dietary Label
                Section(header: Text("Dietary Preference (Required)")) {
                    Picker("Select Diet", selection: $settings.selectedDiet) {
                        ForEach(["Balanced", "High-Fiber", "High-Protein", "Low-Carb", "Low-Fat", "Low-Sodium"], id: \.self) { diet in
                            Text(diet)
                        }
                    }
                }
                
                // Section 2: Calorie Budget
                Section(header: Text("Maximum Calories (Required)")) {
                    Stepper(value: $settings.maxCalories, in: 100...5000, step: 100) {
                        HStack {
                            Text("Max Calories:")
                            Spacer()
                            Text("\(settings.maxCalories) kcal")
                                .foregroundColor(.red)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                // Section 3: Health Constraints
                Section(header: Text("Health Constraints (Optional)")) {
                    ForEach(HealthConstraint.allCases) { constraint in
                        Toggle(constraint.rawValue, isOn: binding(for: constraint.rawValue))
                    }
                }
            }
            .navigationTitle("Meal Preferences")
            .onChange(of: activeConstraints) { newConstraints in
                // When the local set changes, save it back to the persistence string
                settings.activeHealthConstraintsString = newConstraints.joined(separator: ",")
                print("Constraints Saved: \(settings.activeHealthConstraintsString)")
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
