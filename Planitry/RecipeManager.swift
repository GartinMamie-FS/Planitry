//
//  RecipeManager.swift
//  Planitry
//
//  Created by Mamie Gartin on 11/17/25.
//
import SwiftUI
import Combine

class RecipeManager: ObservableObject {
    @Published var savedRecipes: [MealModel] = []
    private let recipesKey = "SavedRecipes"
    
    init() {
        // Load recipes from UserDefaults
        loadRecipes()
    }
    
    func deleteRecipe(offsets: IndexSet) {
        // Remove items from the array at the specified indices
        savedRecipes.remove(atOffsets: offsets)
        // Save the updated list
        saveRecipes()
        print("🗑️ Deleted recipe(s). New count: \(savedRecipes.count)")
    }
    
    func addRecipe(_ meal: MealModel) {
        // Prevent duplicates (optional)
        if !savedRecipes.contains(where: { $0.id == meal.id }) {
            savedRecipes.append(meal)
            saveRecipes()
        }
    }
    
    // MARK: - Persistence Logic (Using UserDefaults for Simplicity)
    
    private func saveRecipes() {
        if let encoded = try? JSONEncoder().encode(savedRecipes) {
            UserDefaults.standard.set(encoded, forKey: recipesKey)
            // 🔥 DEBUG PRINT: Confirm data was written
            print("✅ Saved \(savedRecipes.count) recipes to UserDefaults.")
        } else {
            print("❌ Failed to encode recipes for saving.")
        }
    }
    
    private func loadRecipes() {
        if let savedData = UserDefaults.standard.data(forKey: recipesKey),
           let decodedRecipes = try? JSONDecoder().decode([MealModel].self, from: savedData) {
            self.savedRecipes = decodedRecipes
            // 🔥 DEBUG PRINT: Confirm data was loaded
            print("✅ Loaded \(self.savedRecipes.count) recipes from UserDefaults.")
        } else {
            print("❌ No saved recipe data found or decoding failed.")
        }
    }
}



struct RecipeView: View {
    @EnvironmentObject var recipeManager: RecipeManager
    
    // Define the primary color to match PlannerView
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)

    var body: some View {
        NavigationView {
            List {
                // Iterate over the published array from the manager
                ForEach(recipeManager.savedRecipes) { meal in
                    // Use a NavigationLink to view the saved recipe details
                    NavigationLink(destination: SavedRecipeDetailView(meal: meal)) {
                        RecipeRow(meal: meal) // Create a simple row view
                    }
                }
                .onDelete(perform: recipeManager.deleteRecipe) // Add swipe-to-delete functionality
            }
            .navigationTitle("My Recipes")
            
            // Apply the custom font style to the title
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Recipes (\(recipeManager.savedRecipes.count))")
                        .font(.system(size: 30, weight: .bold)) // Match PlannerView style
                        .foregroundColor(primaryColor)          // Apply custom color
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            
            // Optional: Show a message if the list is empty
            .overlay {
                if recipeManager.savedRecipes.isEmpty {
                    ContentUnavailableView(
                        "No Saved Recipes",
                        systemImage: "bookmark.slash",
                        description: Text("Tap 'Save Recipe' on a meal idea to see it appear here.")
                    )
                }
            }
        }
    }
}
struct RecipeRow: View {
    let meal: MealModel

    var body: some View {
        HStack {
            // Placeholder for a small image (optional)
            AsyncImage(url: URL(string: meal.imageUrl)) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                // Main title of the recipe
                Text(meal.label)
                    .font(.headline)
                    .lineLimit(1)
                
                // Subtitle/details
                Text("\(meal.calculatedCalories) kcal per serving | \(meal.source)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
struct SavedRecipeDetailView: View {
    let meal: MealModel
    
    // 1. Get the tool to open external URLs
    @Environment(\.openURL) var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // --- Image Section ---
                AsyncImage(url: URL(string: meal.imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "fork.knife.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 250)
                .clipped()
                
                // 2. Add the View Full Recipe Button
                if !meal.url.isEmpty, let url = URL(string: meal.url) {
                    
                    Button {
                        // Action: Use the openURL environment variable to open the link
                        openURL(url)
                    } label: {
                        Text("View Full Recipe on \(meal.source)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red) // Use your accent color
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                } else {
                    // Fallback if the URL is missing or empty
                    Text("Recipe source link unavailable.")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // --- Details and Ingredients Section ---
                VStack(alignment: .leading, spacing: 10) {
                    Text(meal.label)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    
                    Text("Source: \(meal.source)") // Display the source name
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Ingredients:")
                        .font(.title2)
                        .fontWeight(.medium)

                    ForEach(meal.ingredients, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                            .font(.body)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(meal.label)
        .navigationBarTitleDisplayMode(.inline)
    }
}
