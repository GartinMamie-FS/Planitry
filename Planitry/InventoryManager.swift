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
    
    /// Deletes ingredients at the specified index set and saves the changes.
    func deleteIngredients(offsets: IndexSet) {
        // Remove the items from the array
        inventory.remove(atOffsets: offsets)
        
        // Save the updated array to AppStorage
        saveInventory()
    }
}
