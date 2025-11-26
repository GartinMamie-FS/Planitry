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
            // 🔑 Wrap content in a VStack for banner integration
            VStack(spacing: 0) {
                
                // 🔑 1. Banner View
                BannerView(
                    title: "My Recipes", // Consistent app name
                    subtitle: "Manage recipes and re-cook favorites!" // Clever contextual subtitle
                )
                
                // The main content area (List)
                if recipeManager.savedRecipes.isEmpty {
                    ContentUnavailableView(
                        "No Saved Recipes",
                        systemImage: "bookmark.slash",
                        description: Text("Tap 'Save Recipe' on a meal idea to see it appear here.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Make ContentUnavailableView fill space
                } else {
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
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            } // End main VStack
            
            // 🔑 2. Navigation bar adjustments (removing custom title styling)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            
            // 🔑 REMOVED .toolbar {} BLOCK ENTIRELY to eliminate the EditButton.
        }
    }
}

// NOTE: RecipeManager, RecipeRow, and SavedRecipeDetailView remain unchanged.
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
    
    // Define the primary color to match ResultsView
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)

    // State to control the DisclosureGroup
    @State private var isIngredientsExpanded: Bool = true // Start expanded for a saved recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Meal Image (Matches ResultsView)
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
                
                // MARK: - Meal Details Card (Adopted from ResultsView)
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
                    
                    // MARK: - Collapsible Ingredients List (Adopted from ResultsView)
                    DisclosureGroup(
                        "Ingredients (\(meal.ingredientCount))",
                        isExpanded: $isIngredientsExpanded // Controls expansion state
                    ) {
                        VStack(alignment: .leading, spacing: 15) {
                            
                            // Ingredient list
                            // We only display the ingredients here since this is a saved view.
                            ForEach(meal.ingredients, id: \.self) { originalIngredient in
                                HStack(alignment: .top) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(primaryColor)
                                        .padding(.top, 5)
                                            
                                    // Display the full original ingredient text (e.g., "1/2 cup milk")
                                    Text(originalIngredient)
                                        .font(.body)
                                    Spacer()
                                }
                            }
                            .padding(.bottom, 10)
                            
                            // MARK: - Recipe Link Button (Adopted from ResultsView Style)
                            if !meal.url.isEmpty, let url = URL(string: meal.url) {
                                Button(action: {
                                    openURL(url)
                                    print("Attempting to open recipe at: \(meal.url)")
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
                            } else {
                                Text("Recipe instructions link unavailable.")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 10)
                            }
                        }
                        .padding(.leading) // Indent the content
                    }
                    .font(.headline)
                    .accentColor(primaryColor) // Color for the arrow
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 30) // Add bottom padding for better scroll experience
                
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationTitle(meal.label)
        .navigationBarTitleDisplayMode(.inline)
    }
}
