//
//  InventoryView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/27/25.
//
import SwiftUI
import Combine

struct InventoryView: View {
    let accentColor = Color(red: 0.1, green: 0.5, blue: 0.1) // Green accent

    // State for the ingredient list, loaded from UserDefaults
    @State private var inventory: [Ingredient] = InventoryView.loadInventory()
    @State private var newItemName: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Header and Input Section
                VStack(spacing: 20) {
                    
                    Text("Manage Your Kitchen **Inventory**")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Track ingredients you have on hand, and find recipes that use what you already own.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)

                // 2. Input Field for New Item
                HStack {
                    TextField("e.g., milk, eggs, bacon...", text: $newItemName)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)

                    Button {
                        addItem()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(accentColor)
                    }
                    .buttonStyle(.plain)
                    .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)

                // 3. Inventory List
                List {
                    Section(header: Text("Your Ingredients (\(inventory.count))")) {
                        if inventory.isEmpty {
                            Text("Your inventory is empty. Start adding items!")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(inventory) { item in
                                Text(item.name.capitalized)
                            }
                            .onDelete(perform: deleteItem)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .frame(maxHeight: 300)

                // 4. Action Buttons
                VStack(spacing: 15) {
                    NavigationLink {
                        RecipeFinderView(inventory: $inventory)
                    } label: {
                        Text("Find Recipes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: accentColor.opacity(0.4), radius: 5, x: 0, y: 5)
                    }
                    .disabled(inventory.isEmpty)

                    Button("Set Expiration Alerts (Coming Soon)") {
                        // Action placeholder
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(accentColor.opacity(0.1))
                    .foregroundColor(accentColor)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Inventory")
            // Save inventory whenever the state changes
            .onChange(of: inventory) { _ in
                InventoryView.saveInventory(inventory)
            }
        }
    }

    // MARK: - Persistence & Actions

    static let inventoryKey = "StoredInventoryKey"

    /// Loads the inventory array from UserDefaults.
    static func loadInventory() -> [Ingredient] {
        if let data = UserDefaults.standard.data(forKey: inventoryKey),
           let decoded = try? JSONDecoder().decode([Ingredient].self, from: data) {
            return decoded
        }
        return [] // Return empty if nothing is stored
    }

    /// Saves the inventory array to UserDefaults.
    static func saveInventory(_ items: [Ingredient]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: inventoryKey)
        }
    }

    /// Adds a new ingredient to the list.
    private func addItem() {
        let trimmedName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            // FIX: Supply default values for quantity and unit to match the Ingredient struct definition
            let newIngredient = Ingredient(name: trimmedName, quantity: 1.0, unit: "pc")

            // Prevent duplicates based on normalized name
            let isDuplicate = inventory.contains { $0.normalizedName == newIngredient.normalizedName }

            if !isDuplicate {
                inventory.append(newIngredient)
            }
            newItemName = "" // Clear the input field
        }
    }

    /// Deletes ingredients from the list using index set from List modifier.
    private func deleteItem(offsets: IndexSet) {
        inventory.remove(atOffsets: offsets)
    }
}
