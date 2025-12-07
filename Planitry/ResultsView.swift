//
//  ResultsView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI
import AVFoundation // 1. Import AVFoundation


// This view displays the details of the single generated meal.
struct ResultsView: View {
    
    @Environment(\.openURL) var openURL
    @EnvironmentObject var listManager: GroceryListManager
    
    let meal: MealModel
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)

    // The single action provided by the parent view
    let onSave: (MealModel) -> Void

    // MARK: - State Properties
    
    @State private var addedItemName: String? = nil
    @State private var showSuccessMessage = false
    @State private var isBulkAdd: Bool = false
    
    // State to control the DisclosureGroup
    @State private var isIngredientsExpanded: Bool = true

    // MARK: - Helper Functions
    
    private func playCheckSound() {
        AudioPlayerHelperC.playSound(named: "check", withExtension: "mp3")
    }
    
    // MARK: - Individual Ingredient Add
    private func addIngredientToList(ingredient: String, cleanName: String) {
        // Play the sound BEFORE the UI update
        playCheckSound()
        
        // Add the clean, parsed ingredient name to the list
        listManager.addItem(ingredientName: cleanName)
        
        addedItemName = cleanName
        isBulkAdd = false
        
        // Explicitly show the success message immediately with animation
        withAnimation {
            showSuccessMessage = true
        }
        
        // Hide the message after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSuccessMessage = false
            }
        }
    }

    // MARK: - Bulk Ingredient Add
    private func addAllIngredientsToList() {
        // Play the sound BEFORE the UI update
        playCheckSound()
        
        // Use the new array of clean names for the grocery list
        for ingredientName in meal.ingredientNames {
            listManager.addItem(ingredientName: ingredientName)
        }

        addedItemName = nil
        isBulkAdd = true
        
        // Explicitly show the success message immediately with animation
        withAnimation {
            showSuccessMessage = true
        }

        // Hide the message after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSuccessMessage = false
            }
        }
    }

    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
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
                        
                        // ... (Meal Name, Calories, Yield) ...
                        
                        // MARK: - Collapsible Ingredients List
                        DisclosureGroup(
                            "Ingredients (\(meal.ingredientCount))",
                            isExpanded: $isIngredientsExpanded
                        ) {
                            VStack(alignment: .leading, spacing: 15) {
                                
                                // Bulk Add Ingredients Button (Action calls addAllIngredientsToList)
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
                                ForEach(Array(zip(meal.ingredients, meal.ingredientNames)), id: \.0) { originalIngredient, cleanIngredientName in
                                    HStack(alignment: .top) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 8))
                                            .foregroundColor(primaryColor)
                                            .padding(.top, 5)
                                                
                                        // Display the full original ingredient text
                                        Text(originalIngredient)
                                            .font(.body)
                                                
                                        Spacer()
                                                
                                        // Button to add the ingredient to the grocery list (Action calls addIngredientToList)
                                        Button(action: {
                                            addIngredientToList(
                                                ingredient: originalIngredient,
                                                cleanName: cleanIngredientName
                                            )
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
                                .padding(.top, 10)                            }
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
            .navigationTitle(meal.label)
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - Success Message Overlay (Unchanged)
            VStack {
                if showSuccessMessage {
                    Text(isBulkAdd ? "All Ingredients Added to List!" : "Added \(addedItemName ?? "Item") to Grocery List!")
                        // ... (Styling) ...
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                }
                Spacer()
            }
            .padding(.top, 20)
            
            // MARK: - Bottom Bar (Save Button Only) (Unchanged)
            VStack(spacing: 0) {
                
                // Save Recipe Button
                Button(action: {
                    onSave(meal)
                }) {
                    Label("Save Recipe", systemImage: "bookmark.fill")
                        // ... (Styling) ...
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
            }
            .background(.ultraThinMaterial)
        }
    }
}
