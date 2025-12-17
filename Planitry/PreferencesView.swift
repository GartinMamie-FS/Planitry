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
    
    // Helper for simple success haptics (for Toggles)
    private func generateToggleHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // Helper for soft impact haptics (for Steppers)
    private func generateStepperHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // 🔑 2. Banner View
                BannerView(title: "Preferences", subtitle: "Customize your meal generation settings")
                
                // 3. Form content
                Form {
                    // MARK: - Section 1: Dietary Label (Picker doesn't usually use haptics)
                    Section {
                        Picker("Select Diet", selection: $selectedDietOption) {
                            ForEach(MealConstraints.DietOption.allCases) { dietOption in
                                Text(dietOption.rawValue)
                                    .tag(dietOption)
                            }
                        }
                    } header: {
                        Text("DIETARY PREFERENCE (REQUIRED)").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                    }
                    
                    // MARK: - Section 2: Calorie Budget (Stepper)
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
                        // 🔑 ADDED: HAPTICS to Stepper
                        .onChange(of: settings.maxCalories) { _ in
                            generateStepperHaptic()
                        }
                    } header: {
                        Text("MAXIMUM CALORIES DAILY (REQUIRED)").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                    }
                    
                    // MARK: - Section 3: Health Constraints (Toggles)
                    Section {
                        ForEach(HealthConstraint.allCases) { constraint in
                            Toggle(constraint.rawValue, isOn: binding(for: constraint.rawValue))
                                // 🔑 ADDED: HAPTICS to Toggle
                                .onChange(of: activeConstraints.contains(constraint.rawValue)) { _ in
                                    generateToggleHaptic()
                                }
                        }
                    } header: {
                        Text("HEALTH CONSTRAINTS (OPTIONAL)").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                    }
                }
            } // End VStack
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            
            // Sync local state when view appears
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
