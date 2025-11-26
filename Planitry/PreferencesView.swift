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
            // 🔑 1. Wrap Form in VStack and remove navigation title from modifier chain
            VStack(spacing: 0) {
                
                // 🔑 2. Banner View
                BannerView(
                    title: "Preferences",
                    subtitle: "Customize your meal generation settings"
                )
                
                // 3. Move Form content here
                Form {
                    // MARK: - Section 1: Dietary Label
                    Section {
                        Picker("Select Diet", selection: $selectedDietOption) {
                            ForEach(MealConstraints.DietOption.allCases) { dietOption in
                                Text(dietOption.rawValue)
                                    .tag(dietOption)
                            }
                        }
                    } header: {
                        // ⭐️ APPLY CONSISTENT STYLING HERE
                        Text("DIETARY PREFERENCE (REQUIRED)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                    
                    // MARK: - Section 2: Calorie Budget
                    Section {
                        Stepper(value: $settings.maxCalories, in: 100...5000, step: 100) {
                            HStack {
                                Text("Max Calories:")
                                Spacer()
                                Text("\(settings.maxCalories) kcal")
                                    .foregroundColor(.red)
                                    .fontWeight(.medium)
                            }
                        }
                    } header: {
                        // ⭐️ APPLY CONSISTENT STYLING HERE
                        Text("MAXIMUM CALORIES DAILY (REQUIRED)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                    
                    // MARK: - Section 3: Health Constraints
                    Section {
                        ForEach(HealthConstraint.allCases) { constraint in
                            Toggle(constraint.rawValue, isOn: binding(for: constraint.rawValue))
                        }
                    } header: {
                        // ⭐️ APPLY CONSISTENT STYLING HERE
                        Text("HEALTH CONSTRAINTS (OPTIONAL)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                }
                // 🔑 4. Remove .navigationTitle("Meal Preferences") from Form's modifier chain
            } // End VStack
            .navigationTitle("") // Clear navigation title bar
            .navigationBarTitleDisplayMode(.inline)
            
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
