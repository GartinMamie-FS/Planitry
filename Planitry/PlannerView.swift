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
    @ObservedObject var settings: UserSettings
    
    // Helper to format the health constraints string for display
    var constraintsDisplay: String {
        let constraints = settings.activeHealthConstraintsString
            .split(separator: ",")
            .map { String($0).replacingOccurrences(of: "Free", with: " Free") }
        
        return constraints.isEmpty ? "None" : constraints.joined(separator: ", ")
    }
    
    // This is the primary color for the buttons and accents
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // MARK: - Header
                VStack(spacing: 8) {
                    Text("Single Meal Generator")
                        .font(.custom("Georgia-Bold", size: 30))
                        .foregroundColor(primaryColor)
                        .padding(.top, 20)
                    
                    Text("Get a quick recipe idea based on your dietary preferences.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                // MARK: - 1. Select Meal Time Card
                VStack(alignment: .leading, spacing: 15) {
                    Text("SELECT MEAL TIME:")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    HStack {
                        // Use a custom button style to match the segmented control look
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
                        Text(settings.selectedDiet)
                            .foregroundColor(primaryColor)
                    }
                    
                    HStack {
                        Text("Health Labels:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(constraintsDisplay)
                            .foregroundColor(.orange) // Using orange to highlight labels
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Max Calories:")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(settings.maxCalories) kcal")
                            .foregroundColor(primaryColor)
                    }
                }
                .padding()
                .background(Color(.systemYellow).opacity(0.1)) // Light yellow background
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                Spacer()
                
                // MARK: - 3. Generate Button (A7)
                // This button will trigger the API call in Week 3
                Button(action: {
                    // TODO: A5, A6, A7: Implement Network Call to Edamam using selectedMealType and settings
                    print("Generating meal idea for \(selectedMealType.rawValue) with constraints...")
                }) {
                    Text("Generate Meal Idea")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true) 
        }
    }
}

// MARK: - Custom Component: Meal Time Button

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
