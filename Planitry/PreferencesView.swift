//
//  PreferencesView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI


struct PreferencesView: View {
    // Access the shared settings object
    @ObservedObject var settings: UserSettings
    
    // Local state to manage toggles (Constraint Toggles)
    @State private var activeConstraints: Set<String>
    
    // NEW: Local state to represent the selected diet as the ENUM
    @State private var selectedDietOption: MealConstraints.DietOption

    init(settings: UserSettings) {
        self._settings = ObservedObject(wrappedValue: settings)
        
        // Initialize active constraints from settings
        _activeConstraints = State(initialValue: Set(settings.activeHealthConstraints))
        
        // NEW: Initialize the enum state by trying to match the currently saved string.
        // If it fails (e.g., first run), default to 'balanced'.
        _selectedDietOption = State(initialValue: MealConstraints.DietOption.allCases.first(where: {
            $0.apiValue == settings.selectedDiet.lowercased()
        }) ?? .balanced)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Section 1: Dietary Label (Now uses the ENUM)
                Section(header: Text("Dietary Preference (Required)")) {
                    Picker("Select Diet", selection: $selectedDietOption) {
                        ForEach(MealConstraints.DietOption.allCases) { dietOption in
                            Text(dietOption.rawValue)
                                .tag(dietOption) // Tagging with the enum value
                        }
                    }
                }
                
                // MARK: - Section 2: Calorie Budget (No Change)
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
                
                // MARK: - Section 3: Health Constraints (No Change)
                Section(header: Text("Health Constraints (Optional)")) {
                    ForEach(HealthConstraint.allCases) { constraint in
                        Toggle(constraint.rawValue, isOn: binding(for: constraint.rawValue))
                    }
                }
            }
            .navigationTitle("Meal Preferences")
            
            // NEW: When the local enum changes, save its API-friendly value to AppStorage
            .onChange(of: selectedDietOption) { newOption in
                settings.selectedDiet = newOption.apiValue // <--- CRITICAL FIX
                print("Diet Saved: \(settings.selectedDiet) (API Value)")
            }
            
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
