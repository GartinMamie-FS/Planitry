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
    
    // 🔑 State to control the collapse state of the Add Ingredient card
    @State private var isAddingNewIngredient: Bool = false
    
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
        
        // Collapse the view after adding
        isAddingNewIngredient = false
    }
    
    // 🚨 UPDATED: Simplified delete logic to call the manager's delete function directly
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
            // 💡 KEY CHANGE: Use VStack(spacing: 0) for consistent banner placement
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
                
                // 💡 KEY CHANGE: Wrap the rest of the content in a ScrollView
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: - Conditional Add Ingredient Card
                        if isAddingNewIngredient {
                            VStack(alignment: .leading, spacing: 15) {
                                
                                // Header and Collapse Button
                                HStack {
                                    Text("ADD NEW INGREDIENT:")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    // Collapse Button
                                    Button(action: { isAddingNewIngredient.toggle() }) {
                                        Image(systemName: "chevron.up.circle.fill")
                                            .foregroundColor(primaryColor)
                                    }
                                }
                                
                                // Input Fields
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
                                
                                // Add Button (The action button)
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
                        } else {
                            // If the state is false, show a simple button to expand the card
                            Button(action: { isAddingNewIngredient.toggle() }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add New Ingredient to Pantry")
                                    Spacer()
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(primaryColor.opacity(0.9))
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                        }
                        
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
                            
                            // The List needs an explicit height/frame inside a ScrollView,
                            // or use the whole ScrollView for the list content.
                            // To maintain the card look, we'll give the list a max frame.
                            // The original code used List inside VStack without a height, which is problematic.
                            // For a list inside a scrollable VStack, use a fixed or maximized frame.
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
                                // Deletion must use the indices of the filtered list, then remove from the original manager list
                                // The .onDelete is still useful for Edit Mode
                                .onDelete(perform: deleteIngredients)
                            }
                            .listStyle(.insetGrouped)
                            // 💡 KEY CHANGE: Explicitly set a frame for the List inside a ScrollView
                            .frame(height: max(200, CGFloat(filteredInventory.count) * 50))
                            
                        }
                        
                    }
                    .padding(.horizontal) // Apply horizontal padding to the scrollable content
                    .padding(.top, 20) // Add top padding to separate from banner
                    
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
            // ⭐️ IMPORTANT: This is crucial for the banner to show up at the top without extra padding
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        // 🔑 EDIT SHEET: Presents the EditIngredientView when ingredientToEdit is non-nil
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
