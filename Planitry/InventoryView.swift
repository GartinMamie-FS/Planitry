//
//  InventoryView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/27/25.
//
import SwiftUI
import Combine

struct InventoryView: View {
    @EnvironmentObject var manager: InventoryManager
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var recipeManager: RecipeManager
    
    // 2. Add Network Manager and State for Search
    @StateObject private var networkManager = NetworkManager()
    @State private var foundMeal: MealModel? = nil
    @State private var alertError: Error? = nil
    @State private var showResults = false // Controls navigation
    
    @State private var newIngredientName: String = ""
    @State private var newIngredientQuantity: String = ""
    @State private var newIngredientUnit: String = ""
    
    @State private var recipeConstraints: String = ""
    @State private var selectedDiet: String = ""
    
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    // MARK: - Add/Delete Logic
    
    private func addIngredient() {
        guard let quantity = Double(newIngredientQuantity.trimmingCharacters(in: .whitespaces)),
              !newIngredientName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        manager.addIngredient(
            name: newIngredientName,
            quantity: quantity,
            unit: newIngredientUnit
        )
        
        // Reset fields
        newIngredientName = ""
        newIngredientQuantity = ""
        newIngredientUnit = ""
    }
    
    private func deleteIngredients(offsets: IndexSet) {
        manager.deleteIngredients(offsets: offsets)
    }
    
    // MARK: - Save Logic (for ResultsView)
    
    private func saveRecipeAction(mealToSave: MealModel) {
            // 1. Use the RecipeManager to save the whole object
            recipeManager.addRecipe(mealToSave)
            
            // 2. Add confirmation print (optional)
            print("Recipe Saved: \(mealToSave.label) (\(mealToSave.id))")
        }

    // MARK: - Networking Logic (Moved from RecipeFinderView)
    
    private func performRecipeSearch() {
        guard !manager.inventory.isEmpty else {
            self.alertError = NSError(domain: "InventoryError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Your inventory is empty. Please add ingredients before searching."])
            return
        }
        
        alertError = nil
        foundMeal = nil
        showResults = false
        
        let ingredientNames = manager.inventory.map { $0.name.lowercased() }
        
        Task {
            let result = await networkManager.fetchRecipeByInventory(
                ingredients: ingredientNames,
                maxCalories: Int(settings.maxCalories),
                selectedDiet: settings.selectedDiet,
                healthConstraints: settings.activeHealthConstraints
            )
            
            await MainActor.run {
                switch result {
                case .success(let meal):
                    self.foundMeal = meal
                    self.showResults = true // Trigger navigation on success
                case .failure(let error):
                    self.alertError = error
                }
            }
        }
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // --- Hidden NavigationLink for Result Transition ---
                // The destination now passes the foundMeal and the save action.
                NavigationLink(
                    destination: Group {
                        if let meal = foundMeal {
                            ResultsView(
                                meal: meal,
                                onSave: saveRecipeAction // Pass the save action
                            )
                        } else {
                            Text("No meal data available.")
                        }
                    },
                    isActive: $showResults,
                    label: { EmptyView() }
                )
                .hidden()
                
                // MARK: - Header
                VStack(spacing: 8) {
                    Text("Pantry Inventory")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(primaryColor)
                        .padding(.top, 20)
                    
                    Text("Track what you have on hand to find the perfect recipe.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // MARK: - Add Ingredient Card
                VStack(alignment: .leading, spacing: 15) {
                    Text("ADD NEW INGREDIENT:")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Group {
                        TextField("Name (e.g., Chicken Breast)", text: $newIngredientName)
                            .padding(.vertical, 8)
                        
                        HStack {
                            TextField("Quantity (e.g., 2)", text: $newIngredientQuantity)
                                .keyboardType(.decimalPad)
                            
                            TextField("Unit (e.g., lbs, cups, unit)", text: $newIngredientUnit)
                        }
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Add Button
                    Button(action: addIngredient) {
                        Text("Add to Inventory")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryColor.opacity(newIngredientName.isEmpty ? 0.5 : 0.9))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(newIngredientName.isEmpty)
                    
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .shadow(radius: 3)
                .padding(.horizontal)
                
                
                // MARK: - Current Inventory List Card
                VStack(alignment: .leading) {
                    Text("YOUR CURRENT INVENTORY (\(manager.inventory.count))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                    
                    List {
                        ForEach(manager.inventory) { item in
                            HStack {
                                Text(item.name.capitalized)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(item.quantity, specifier: "%.1f") \(item.unit)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deleteIngredients)
                    }
                    .listStyle(.insetGrouped)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Action Button (Triggers Search)
                if !manager.inventory.isEmpty {
                    
                    Button(action: performRecipeSearch) {
                        if networkManager.isFetching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.7))
                                .cornerRadius(12)
                        } else {
                            Text("Find Recipes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.9))
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .disabled(networkManager.isFetching)
                }
                
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        // MARK: - Error Alert
        .alert("Search Error", isPresented: Binding(
            get: { alertError != nil },
            set: { _ in alertError = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertError?.localizedDescription ?? "An unknown error occurred while searching for a recipe.")
        }
    }
}
