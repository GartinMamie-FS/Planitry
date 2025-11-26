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
    
    // 🔑 NEW STATE FOR SEARCH FILTERING
    @State private var searchText: String = ""
    
    @State private var recipeConstraints: String = ""
    @State private var selectedDiet: String = ""
    
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    // 🔑 NEW STATE: Tracks the ingredient selected for editing
    @State private var ingredientToEdit: Ingredient? = nil
    
    // MARK: - Computed Filtered Inventory
    var filteredInventory: [Ingredient] {
        if searchText.isEmpty {
            return manager.inventory
        } else {
            return manager.inventory.filter {
                // Filter by name, case-insensitive
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Add/Delete Logic
    
    private func addIngredient() {
        // We will default quantity to 1.0 and unit to "unit" if fields are empty
        let quantityString = newIngredientQuantity.trimmingCharacters(in: .whitespaces)
        let unitString = newIngredientUnit.trimmingCharacters(in: .whitespaces)
        
        guard !newIngredientName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        manager.addIngredient(
            name: newIngredientName,
            quantity: Double(quantityString) ?? 1.0, // Default to 1.0
            unit: unitString.isEmpty ? "unit" : unitString // Default to "unit"
        )
        
        // Reset fields
        newIngredientName = ""
        newIngredientQuantity = ""
        newIngredientUnit = ""
    }
    
    // Simplified delete logic to call the manager's delete function directly
    private func deleteIngredients(offsets: IndexSet) {
        // Find the actual items from the filtered list
        let itemsToDelete = offsets.map { filteredInventory[$0] }
        
        // Pass the IDs to the manager for removal from the main list
        let idsToDelete = itemsToDelete.map { $0.id }
        manager.removeIngredients(with: idsToDelete)
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
            // Use VStack(spacing: 0) for consistent banner placement
            VStack(spacing: 0) {
                
                // --- Hidden NavigationLink for Result Transition ---
                NavigationLink(
                    destination: Group {
                        if let meal = foundMeal {
                            ResultsView(
                                meal: meal,
                                onSave: saveRecipeAction // Pass the save action
                            )
                        } else {
                            // 💡 Added loading view for consistency with PlannerView
                            VStack(spacing: 15) {
                                ProgressView()
                                    .scaleEffect(1.5, anchor: .center)
                                    .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                                    
                                Text("Searching for recipes based on your pantry...")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                    
                                Text("Pantry: \(manager.inventory.count) ingredients | Diet: \(settings.selectedDiet.capitalized)")
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
                
                // ⭐️ MARK: - HEADER (REPLACED WITH BANNERVIEW)
                BannerView(
                    title: "Inventory",
                    subtitle: "Track what you have to find the perfect recipe."
                )
                
                // ✅ KEY CHANGE: Move Add Ingredient Input HERE (outside the ScrollView)
                VStack(alignment: .leading, spacing: 10) {
                    
                    // ✅ MARK: - GROCERY LIST STYLE INPUT FIELD
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ADD NEW INGREDIENT:")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.leading, 5)

                        // 🔑 MAIN INPUT ROW (Mimicking Grocery List)
                        HStack {
                            // Combined Text Field
                            TextField(
                                "Name (e.g., 2 lbs Chicken Breast)", // Example hint for multiple fields
                                text: $newIngredientName
                            )
                            
                            // Condensed Quantity Field
                            TextField("Qty", text: $newIngredientQuantity)
                                .keyboardType(.decimalPad)
                                .frame(width: 50)
                                .multilineTextAlignment(.trailing)

                            // Condensed Unit Field
                            TextField("Unit", text: $newIngredientUnit)
                                .frame(width: 50)
                                .multilineTextAlignment(.trailing)

                            // Add Button
                            Button {
                                addIngredient()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(primaryColor)
                            }
                            .disabled(newIngredientName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .padding(.trailing, 5) // Keep the trailing padding for the button
                        }
                        .padding(10)                         .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 5)
                        
                    }
                    
                }
                .padding(.horizontal) // Apply horizontal padding to the overall input block
                .padding(.top, 20) // Add top padding to separate from banner
                .padding(.bottom, 10)
                
                // 💡 Wrap the rest of the content (Inventory List) in a ScrollView
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: - Current Inventory List Card (Bigger and Searchable)
                        VStack(alignment: .leading) {
                            Text("YOUR CURRENT INVENTORY (\(filteredInventory.count))") // Updated count
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
                            
                            // 🔑 SEARCH FIELD
                            TextField("Search your inventory...", text: $searchText)
                                .padding(8)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                                .padding(.horizontal, 5)
                                .padding(.bottom, 5)
                            
                            List {
                                // 🔑 LIST USES FILTERED INVENTORY
                                ForEach(filteredInventory) { item in
                                    HStack {
                                        Text(item.name.capitalized)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(item.quantity, specifier: "%.1f") \(item.unit)")
                                            .foregroundColor(.secondary)
                                    }
                                    // 🔑 ADD SWIPE ACTIONS FOR EDIT AND DELETE
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        // 1. Delete Action
                                        Button(role: .destructive) {
                                            // Call the custom delete function which handles the filtered list
                                            if let index = filteredInventory.firstIndex(where: { $0.id == item.id }) {
                                                deleteIngredients(offsets: IndexSet(integer: index))
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        // 2. Edit Action
                                        Button {
                                            // Set the ingredient to edit to present the sheet
                                            ingredientToEdit = item
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                                }
                                
                                .onDelete(perform: deleteIngredients)
                            }
                            .listStyle(.insetGrouped)
                            
                            .frame(height: max(200, CGFloat(filteredInventory.count) * 50))
                            
                        }
                        
                    }
                    .padding(.horizontal)
                } // End ScrollView
                
                // MARK: - Action Button (Triggers Search - Now FIXED at the bottom)
                // 💡 KEY CHANGE: Moved the button outside the ScrollView
                if !manager.inventory.isEmpty {
                    
                    Button(action: performRecipeSearch) {
                        if networkManager.isFetching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.orange.opacity(0.7))
                                .cornerRadius(12)
                        } else {
                            Text("Find Recipes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(primaryColor)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .disabled(networkManager.isFetching)
                }
                
            }
          
            .navigationTitle("")
            .navigationBarHidden(true)
        }
      
        .sheet(item: $ingredientToEdit) { ingredient in
            EditIngredientView(
                inventoryManager: manager,
                ingredient: ingredient
            )
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
