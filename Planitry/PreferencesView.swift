//
//  PreferencesView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI


struct PreferencesView: View {
    // Access the shared settings object
    @EnvironmentObject var settings: UserSettings
    
    @State private var activeConstraints: Set<String> = []
    
    @State private var selectedDietOption: MealConstraints.DietOption = .balanced
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Section 1: Dietary Label
                Section(header: Text("Dietary Preference (Required)")) {
                    Picker("Select Diet", selection: $selectedDietOption) {
                        ForEach(MealConstraints.DietOption.allCases) { dietOption in
                            Text(dietOption.rawValue)
                                .tag(dietOption)
                        }
                    }
                }
                
                // MARK: - Section 2: Calorie Budget
                Section(header: Text("Maximum Calories Daily (Required)")) {
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
                
                // MARK: - Section 3: Health Constraints
                Section(header: Text("Health Constraints (Optional)")) {
                    ForEach(HealthConstraint.allCases) { constraint in
                        Toggle(constraint.rawValue, isOn: binding(for: constraint.rawValue))
                    }
                }
            }
            .navigationTitle("Meal Preferences")
            
   
            .onAppear {
                // 1. Load constraints from settings string into local Set
                let currentConstraints = settings.activeHealthConstraintsString.split(separator: ",").map { String($0) }
                self.activeConstraints = Set(currentConstraints)
                
                // 2. Load selected diet from settings string into local Enum
                self.selectedDietOption = MealConstraints.DietOption.allCases.first(where: {
                    $0.apiValue == settings.selectedDiet.lowercased()
                }) ?? .balanced
            }
            
            // Sync local state back to persistence layer when it changes
            .onChange(of: selectedDietOption) { newOption in
                settings.selectedDiet = newOption.apiValue
                print("Diet Saved: \(settings.selectedDiet) (API Value)")
            }
            
            .onChange(of: activeConstraints) { newConstraints in
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
