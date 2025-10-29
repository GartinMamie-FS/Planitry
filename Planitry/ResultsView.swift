//
//  ResultsView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI


// MARK: - Results View (A8)

// This view displays the details of the single generated meal.
struct ResultsView: View {
    
    @Environment(\.openURL) var openURL
    @EnvironmentObject var listManager: GroceryListManager // Inject the manager
    
    let meal: MealModel
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)

    // State for visual feedback when an item is added
    @State private var addedItemName: String? = nil
    @State private var showSuccessMessage = false

    // MARK: - Helper Function
    private func addIngredientToList(ingredient: String) {
        listManager.addItem(ingredientName: ingredient)
        
        // Show brief success feedback
        addedItemName = ingredient
        showSuccessMessage = true
        
        // Hide the message after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSuccessMessage = false
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Meal Image
                AsyncImage(url: URL(string: meal.imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        Image(systemName: "photo.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .frame(height: 250)
                    }
                }
                .frame(height: 250)
                .clipped()
                
                // MARK: - Meal Details Card
                VStack(alignment: .leading, spacing: 15) {
                    
                    // Meal Name
                    Text(meal.label)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                    
                    // Calorie Count
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Calories Per Serving:")
                            .fontWeight(.medium)
                        Text("\(meal.calculatedCalories) kcal")
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                    }
                    .font(.title3)
                    
                    Text("Yields: \(Int(meal.yield)) servings (Total Recipe Calories: \(Int(meal.calories.rounded())) kcal)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    // MARK: - Ingredients List
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Ingredients (\(meal.ingredientCount))")
                            .font(.headline)
                        
                        // Display the list of ingredients with 'Add to List' functionality
                        ForEach(meal.ingredients, id: \.self) { ingredient in
                            HStack(alignment: .top) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(primaryColor)
                                    .padding(.top, 5)
                                
                                Text(ingredient)
                                    .font(.body)
                                
                                Spacer()
                                
                                // NEW: Button to add the ingredient to the grocery list
                                Button(action: {
                                    addIngredientToList(ingredient: ingredient)
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "cart.badge.plus")
                                            .font(.callout)
                                    }
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle()) // Ensure tap target is clean
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    
                    Divider()
                    
                    // MARK: - Recipe Link Button
                    Button(action: {
                        if let url = URL(string: meal.url) {
                            openURL(url)
                            print("Attempting to open recipe at: \(meal.url)")
                        }
                    }) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                            Text("View Full Recipe Instructions from \(meal.source)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                }
                .padding()
                
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationTitle("Your Meal Idea")
        .navigationBarTitleDisplayMode(.inline)
        // MARK: - Success Message Overlay
        .overlay(
            VStack {
                if showSuccessMessage {
                    Text("Added to Grocery List!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                }
                Spacer()
            }
            .padding(.top, 20)
            , alignment: .top
        )
    }
}
