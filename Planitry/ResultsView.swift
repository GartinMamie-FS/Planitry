//
//  ResultsView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI

// This view displays the details of the single generated meal.
struct ResultsView: View {
    
    @Environment(\.openURL) var openURL
    @EnvironmentObject var listManager: GroceryListManager
    
    let meal: MealModel
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)

    // The single action provided by the parent view
    let onSave: (MealModel) -> Void // Action to save the ID and Name

    // MARK: - State Properties
    
    @State private var addedItemName: String? = nil
    @State private var showSuccessMessage = false
    @State private var isBulkAdd: Bool = false
    
    // State to control the DisclosureGroup
    @State private var isIngredientsExpanded: Bool = false

    // MARK: - Helper Functions
    
    private func addIngredientToList(ingredient: String) {
        listManager.addItem(ingredientName: ingredient)
        
        addedItemName = ingredient
        isBulkAdd = false
        showSuccessMessage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSuccessMessage = false
            }
        }
    }

    private func addAllIngredientsToList() {
        for ingredient in meal.ingredients {
            listManager.addItem(ingredientName: ingredient)
        }

        addedItemName = nil
        isBulkAdd = true
        showSuccessMessage = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSuccessMessage = false
            }
        }
    }

    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) { // Use ZStack for the sticky bottom bar
            
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
                        
                        // MARK: - Collapsible Ingredients List
                        DisclosureGroup(
                            "Ingredients (\(meal.ingredientCount))",
                            isExpanded: $isIngredientsExpanded
                        ) {
                            VStack(alignment: .leading, spacing: 15) {
                                
                                // Bulk Add Ingredients Button
                                Button(action: addAllIngredientsToList) {
                                    HStack {
                                        Image(systemName: "cart.fill.badge.plus")
                                        Text("Add All Ingredients to List")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(primaryColor)
                                    .cornerRadius(10)
                                }
                                .padding(.vertical, 5)
                                
                                // Ingredient list
                                ForEach(meal.ingredients, id: \.self) { ingredient in
                                    HStack(alignment: .top) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 8))
                                            .foregroundColor(primaryColor)
                                            .padding(.top, 5)
                                            
                                        Text(ingredient)
                                            .font(.body)
                                            
                                        Spacer()
                                            
                                        // Button to add the ingredient to the grocery list
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
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.bottom, 10)
                                
                                // MARK: - Recipe Link Button (Moved inside DisclosureGroup)
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
                            .padding(.leading) // Indent the content
                        }
                        .font(.headline)
                        .accentColor(primaryColor) // Color for the arrow
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Ensure space for the floating bottom bar
                    
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationTitle("Your Meal Idea")
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - Success Message Overlay
            VStack {
                if showSuccessMessage {
                    Text(isBulkAdd ? "All Ingredients Added to List!" : "Added \(addedItemName ?? "Item") to Grocery List!")
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
            
            // MARK: - Bottom Bar (Save Button Only)
            VStack(spacing: 0) {
                
                // Save Recipe Button
                Button(action: {
                    onSave(meal)
                }) {
                    Label("Save Recipe", systemImage: "bookmark.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
            }
            .background(.ultraThinMaterial) 
        }
    }
}
