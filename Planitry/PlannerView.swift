//
//  PlannerView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI


// MARK: - Planner View (A4)

struct PlannerView: View {
    // 1. Local State for Meal Selection
    @State private var selectedMealType: MealType = .breakfast

    // 2. Access to Global Preferences
    @EnvironmentObject var settings: UserSettings
    
    @EnvironmentObject var recipeManager: RecipeManager

    // 3. Network Manager
    @StateObject private var networkManager = NetworkManager()

    // SINGLE MEAL STATE
    @State private var foundMeal: MealModel? = nil

    // State to trigger an alert on network error
    @State private var alertError: NetworkError? = nil

    // State to trigger navigation on success
    @State private var showResults = false

    // Primary color for styling
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)

    // Helper to format the health constraints string for display
    var constraintsDisplay: String {
        let constraints = settings.activeHealthConstraints
            .map { $0.replacingOccurrences(of: "-", with: " ").capitalized }
        return constraints.isEmpty ? "None" : constraints.joined(separator: ", ")
    }

    // MARK: - Action Functions

    func saveMeal(mealToSave: MealModel) {
        recipeManager.addRecipe(mealToSave)
    }

    // MARK: - Network Action Function
    func generateMeal() {
        alertError = nil
        self.showResults = true

        // 1. Construct constraints object from user settings
        let constraints = MealConstraints(
            mealType: selectedMealType.rawValue,
            maxCalories: settings.maxCalories,
            healthConstraints: settings.activeHealthConstraints
        )

        // 2. Execute network call
        Task {
            // Reset state before fetching
            await MainActor.run {
                self.foundMeal = nil
            }

            let result = await networkManager.fetchMeal(
                for: constraints,
                selectedDiet: settings.selectedDiet
            )

            // 3. Update UI state based on result
            await MainActor.run {
                switch result {
                case .success(let meal):
                    // Store the new meal, NavigationLink stays active
                    self.foundMeal = meal
                case .failure(let error):
                    self.alertError = error
                    // If an error occurs, dismiss the results view
                    self.showResults = false
                }
            }
        }
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Top-level VStack controls structure
                
                // MARK: - Header (BannerView)
                // This is OUTSIDE the ScrollView's padding, allowing it to stretch.
                BannerView(
                    title: "Meal Planner",
                    subtitle: "Crafting your next meal idea."
                )

                // The rest of the content goes inside a ScrollView for necessary padding
                // and to allow the constraints cards to be scrollable.
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // --- Hidden NavigationLink for Result Transition ---
                        NavigationLink(
                            destination: Group {
                                if let meal = foundMeal {
                                    ResultsView(
                                        meal: meal,
                                        onSave: saveMeal // Pass the action closure
                                    )
                                } else {
                                    VStack(spacing: 15) {
                                        ProgressView()
                                            .scaleEffect(1.5, anchor: .center)
                                            .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                                            
                                        Text("Searching for the perfect meal...")
                                            .font(.title3)
                                            .foregroundColor(.secondary)
                                            
                                        Text("Based on your \(settings.selectedDiet.capitalized) diet and \(settings.maxCalories / 3) kcal limit.")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            },
                            isActive: $showResults,
                            label: { EmptyView() }
                        )
                        .hidden()
                        
                        // MARK: - 1. Select Meal Time Card
                        VStack(alignment: .leading, spacing: 15) {
                            Text("SELECT MEAL TIME:")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            HStack {
                                ForEach(MealType.allCases) { meal in
                                    MealTimeButton(
                                        meal: meal,
                                        selectedMealType: $selectedMealType,
                                        primaryColor: primaryColor
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .shadow(radius: 3)
                        
                        // MARK: - 2. Current Constraints Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Constraints:")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding(.bottom, 4)
                            
                            HStack {
                                Text("Diet:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(settings.selectedDiet.capitalized)
                                    .foregroundColor(primaryColor)
                            }
                            
                            HStack {
                                Text("Health Labels:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(constraintsDisplay)
                                    .foregroundColor(.orange)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            HStack {
                                Text("Max Calories (Recipe Est.):")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(settings.maxCalories / 3) kcal")
                                    .foregroundColor(primaryColor)
                            }
                        }
                        .padding()
                        .background(Color(.systemYellow).opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        Spacer()
                        
                        // MARK: - 3. Generate Button (Note: The button is better outside the ScrollView)
                        // Moving the button outside the ScrollView ensures it's always visible.
                    }
                    // Apply horizontal padding to the scrollable content
                    .padding(.horizontal)
                    .padding(.top, 20) // Add top padding to separate from banner
                } // End ScrollView
                
                // MARK: - 3. Generate Button (Moved outside ScrollView)
                Button(action: generateMeal) {
                    if networkManager.isFetching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryColor.opacity(0.7))
                            .cornerRadius(12)
                    } else {
                        Text("Generate Meal Idea")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryColor.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom) // Add some bottom padding above the edge
                .disabled(networkManager.isFetching)

            } // End top-level VStack
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        // MARK: - Error Alert
        .alert("Network Error", isPresented: Binding(
            get: { alertError != nil },
            set: { _ in alertError = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertError?.localizedDescription ?? "An unknown error occurred while fetching the meal.")
        }
    }
}

// Meal Time Button
struct MealTimeButton: View {
    let meal: MealType
    @Binding var selectedMealType: MealType
    let primaryColor: Color
    
    var isSelected: Bool { meal == selectedMealType }
    
    var body: some View {
        Button(action: {
            selectedMealType = meal
        }) {
            Text(meal.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundColor(isSelected ? .white : .gray)
                .background(isSelected ? primaryColor : Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(primaryColor.opacity(isSelected ? 0 : 0.5), lineWidth: 1)
                )
        }
    }
}
