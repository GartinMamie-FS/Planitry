//
//  RecipeFinderView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/27/25.
//
import SwiftUI
import Combine

struct RecipeFinderView: View {
    // Inventory is passed as a binding
    @Binding var inventory: [Ingredient]
    
    @State private var foundMeal: MealModel? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    let primaryColor = Color(red: 0.1, green: 0.5, blue: 0.1)
    
    var body: some View {
        Group {
            if isLoading {
                // Show loading indicator while the API call is in progress
                VStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                    Text("Searching for the perfect recipe...")
                        .foregroundColor(.gray)
                }
            } else if let errorMessage = errorMessage {
                // Show error message if the search failed
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Recipe Search Failed")
                        .font(.headline)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Button("Try Search Again") {
                        performRecipeSearch()
                    }
                    .padding(.top, 10)
                }
            } else if let meal = foundMeal {
                // SUCCESS: Pass the found meal to the existing ResultsView
                ResultsView(meal: meal)
            } else {
                // Default view before the search has completed/started
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(primaryColor)
                    
                    Text("Ready to Find Recipes?")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your inventory has \(inventory.count) ingredients. Tap the button below to start the search!")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Search Now") {
                        performRecipeSearch()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(inventory.isEmpty ? Color.gray : primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(inventory.isEmpty)
                    
                    if inventory.isEmpty {
                        Text("Add ingredients in the Inventory tab first!")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(.top, 50)
        .navigationTitle("Find Recipes")
    }
    
    // MARK: - Networking Logic (Updated to use the Edamam API)
    
    private func performRecipeSearch() {
        guard !inventory.isEmpty else {
            self.errorMessage = "Your inventory is empty. Please add ingredients before searching."
            return
        }
        
        // 1. Reset state
        isLoading = true
        errorMessage = nil
        foundMeal = nil
        
        let ingredientNames = inventory.map { $0.name.lowercased() }
        let networkManager = NetworkManager()
        
        // 2. Start the asynchronous network call
        Task {
            // Await the result from the dedicated inventory search method
            let result = await networkManager.fetchRecipeByInventory(ingredients: ingredientNames)
            
            // 3. Update UI state on the MainActor
            await MainActor.run {
                self.isLoading = false
                
                switch result {
                case .success(let meal):
                    self.foundMeal = meal
                    self.errorMessage = nil // Clear error on success
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.foundMeal = nil // Clear meal on failure
                }
            }
        }
    }
}
