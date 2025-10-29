//
//  GroceryListManager.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/29/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - 1. Grocery List Item Model

/// Represents a single item on the user's grocery list.
struct GroceryListItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let dateAdded = Date()
    var isChecked: Bool = false
}

// MARK: - 2. Grocery List Manager

/// Observable object to manage the state of the user's grocery list.
class GroceryListManager: ObservableObject {
    // Initialize with some dummy data to showcase the checked feature
    @Published var groceryList: [GroceryListItem] = [
        GroceryListItem(name: "Milk (1 gallon)", isChecked: true), // Checked
        GroceryListItem(name: "Eggs (dozen)", isChecked: false), // Remaining
        GroceryListItem(name: "Whole Wheat Bread", isChecked: false) // Remaining
    ]
    
    // For simple persistence in a real app, this would use Firestore/CoreData.

    /// Adds an ingredient name to the grocery list if it's not already present.
    func addItem(ingredientName: String) {
        let normalizedName = ingredientName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !groceryList.contains(where: { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalizedName }) {
            // New items are always added as unchecked
            let newItem = GroceryListItem(name: ingredientName, isChecked: false)
            groceryList.append(newItem)
            print("Added to grocery list: \(ingredientName)")
        } else {
            print("Item already exists in grocery list.")
        }
    }
    
    /// NEW: Toggles the checked status of a specific item.
    func toggleItemChecked(item: GroceryListItem) {
        // Find the index of the item and toggle its boolean property
        if let index = groceryList.firstIndex(where: { $0.id == item.id }) {
            groceryList[index].isChecked.toggle()
        }
    }
    
    /// Removes items from the grocery list.
    func removeItem(at offsets: IndexSet) {
        // To handle section separation, we need to determine which items correspond to the offsets.
        // For simplicity in this example, we will let the view handle which list is being deleted from.
        // A more robust solution would require the manager to handle the split.
        groceryList.remove(atOffsets: offsets)
    }
    
    /// Clears the entire grocery list.
    func clearList() {
        groceryList.removeAll()
        print("Grocery list cleared.")
    }
}
