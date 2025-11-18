//
//  InventoryManager.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/29/25.
//

import SwiftUI
import Foundation
import Combine


// MARK: - InventoryManager (Observable Object for AppStorage Persistence)

class InventoryManager: ObservableObject {
    
    // 1. Storage for the encoded data using @AppStorage
    @AppStorage("myInventoryData") private var inventoryData: Data?
    
    // 2. Published property for the inventory array.
    @Published var inventory: [Ingredient] = []
    
    init() {
        // Load the inventory immediately upon initialization
        loadInventory()
    }
    
    // MARK: - Persistence Logic
    
    /// Decodes data from AppStorage into the 'inventory' array.
    private func loadInventory() {
        guard let data = inventoryData else {
            // If there's no data saved, inventory remains empty ([])
            return
        }
        
        do {
            // Decode the data back into an array of Ingredient
            let decodedInventory = try JSONDecoder().decode([Ingredient].self, from: data)
            self.inventory = decodedInventory
        } catch {
            print("Error decoding inventory from AppStorage: \(error)")
            // If decoding fails (e.g., due to an old data structure), reset to empty
            self.inventory = []
        }
    }
    
    /// Encodes the current 'inventory' array and saves it to AppStorage.
    private func saveInventory() {
        do {
            // Encode the current inventory array into Data
            let data = try JSONEncoder().encode(self.inventory)
            inventoryData = data
        } catch {
            print("Error encoding and saving inventory to AppStorage: \(error)")
        }
    }
    
    // MARK: - Public Modification Methods
    
    /// Adds a new ingredient and saves the changes.
    func addIngredient(name: String, quantity: Double, unit: String) {
        // Assuming Ingredient is defined elsewhere with Codable and Identifiable conformance
        let newIngredient = Ingredient(
            name: name.trimmingCharacters(in: .whitespaces),
            quantity: quantity,
            unit: unit.trimmingCharacters(in: .whitespaces)
        )
        // Append the new item
        inventory.append(newIngredient)
        
        // Save the updated array to AppStorage
        saveInventory()
    }
    
    /// 🔑 NEW FUNCTION: Updates an existing ingredient by its ID and saves the changes.
    func updateIngredient(id: UUID, newName: String, newQuantity: Double, newUnit: String) {
        if let index = inventory.firstIndex(where: { $0.id == id }) {
            // Update the properties
            inventory[index].name = newName.trimmingCharacters(in: .whitespaces)
            inventory[index].quantity = newQuantity
            inventory[index].unit = newUnit.trimmingCharacters(in: .whitespaces)
            
            // Save the updated array to AppStorage
            saveInventory()
        } else {
            print("Error: Ingredient with ID \(id) not found for update.")
        }
    }
    
    /// 🔑 NEW FUNCTION: Removes ingredients based on a list of IDs and saves the changes.
    func removeIngredients(with ids: [UUID]) {
        // Filter out any ingredients whose IDs are in the provided list
        inventory.removeAll { ids.contains($0.id) }
        
        // Save the updated array to AppStorage
        saveInventory()
    }
    
    // The original `deleteIngredients(offsets: IndexSet)` is no longer necessary
    // if the view calls `removeIngredients(with:)`.
    
    // MARK: - Item Transfer Logic
    
    /// Converts a purchased GroceryListItem into an Ingredient and adds it to the inventory.
    /// Purchased items use placeholder quantity/unit since GroceryListItem lacks that detail.
    func receivePurchasedItem(item: GroceryListItem) {
        let normalizedName = item.name.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Prevent adding duplicates if the item (by name) is already in the inventory
        if inventory.contains(where: { $0.normalizedName == normalizedName }) {
            print("Item \(item.name) already in inventory. Skipping addition.")
            return
        }
        
        // Use a placeholder quantity and unit (1.0 "unit")
        // Assuming Ingredient is defined elsewhere
        let newIngredient = Ingredient(
            name: item.name,
            quantity: 1.0,
            unit: "unit"
        )
        
        inventory.append(newIngredient)
        saveInventory()
        print("Purchased item \(item.name) successfully moved to Inventory.")
    }
}
