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
struct GroceryListItem: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let dateAdded: Date
    var isChecked: Bool = false
    
    // Custom initializer to match previous usage
    init(name: String, isChecked: Bool = false) {
        self.id = UUID()
        self.name = name
        self.isChecked = isChecked
        self.dateAdded = Date()
    }
}

// MARK: - 2. Grocery List Manager

class GroceryListManager: ObservableObject {
    @Published var groceryList: [GroceryListItem] = []
    
    // Key used for UserDefaults
    private let persistenceKey = "PersistedGroceryList"
    
    // Combine set to hold our subscription that monitors the list for changes
    private var cancellables = Set<AnyCancellable>()
    
    // This closure will be set by ContentView to communicate with the InventoryManager
    private var inventoryTransferHandler: ((GroceryListItem) -> Void)?
        
    // Updated initializer to accept the transfer handler closure
    init(inventoryTransferHandler: ((GroceryListItem) -> Void)? = nil) {
        self.inventoryTransferHandler = inventoryTransferHandler

        // 1. Load the list from UserDefaults
        load()
        
        // 2. Subscribe to changes and save them automatically
        $groceryList
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
    }

    
    // MARK: - Persistence Handlers
    
    private func save() {
        do {
            let encoder = JSONEncoder()
            // Encode the entire array of grocery list items
            let data = try encoder.encode(groceryList)
            // Save the data to UserDefaults
            UserDefaults.standard.set(data, forKey: persistenceKey)
            print("Grocery list saved locally (\(groceryList.count) items).")
        } catch {
            print("Error saving grocery list: \(error.localizedDescription)")
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: persistenceKey) {
            do {
                let decoder = JSONDecoder()
                // Decode the data back into an array of GroceryListItem
                groceryList = try decoder.decode([GroceryListItem].self, from: data)
                print("Grocery list loaded locally (\(groceryList.count) items).")
            } catch {
                print("Error loading grocery list: \(error.localizedDescription)")
                // Clear corrupted data if decoding fails
                UserDefaults.standard.removeObject(forKey: persistenceKey)
            }
        }
    }

    // MARK: - Item Management
    
    /// Adds an ingredient name to the grocery list if it's not already present.
    func addItem(ingredientName: String) {
        let normalizedName = ingredientName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !groceryList.contains(where: { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalizedName }) {
            // New items are always added as unchecked
            let newItem = GroceryListItem(name: ingredientName, isChecked: false)
            // The sink will detect this change and call save()
            groceryList.append(newItem)
            print("Added to grocery list: \(ingredientName)")
        } else {
            print("Item already exists in grocery list.")
        }
    }
    
    /// Toggles the checked status of a specific item.
    func toggleItemChecked(item: GroceryListItem) {
        // Find the index of the item and toggle its boolean property
        if let index = groceryList.firstIndex(where: { $0.id == item.id }) {
            // Toggle the checked state
            groceryList[index].isChecked.toggle()
            
            if groceryList[index].isChecked {
                inventoryTransferHandler?(groceryList[index])
            }
        }
    }
    
    /// Removes items from the grocery list.
    func removeItem(item: GroceryListItem) {
        // The sink will detect this change and call save()
        groceryList.removeAll { $0.id == item.id }
    }
    
    /// Clears the entire grocery list.
    func clearList() {
        // The sink will detect this change and call save()
        groceryList.removeAll()
        print("Grocery list cleared.")
    }
}

// MARK: - 3. Individual Item Row

struct ShoppingListItemRow: View {
    let item: GroceryListItem
    @ObservedObject var listManager: GroceryListManager
    let primaryColor: Color
    
    var body: some View {
        HStack {
            // Checkmark or circle icon
            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(item.isChecked ? .green : primaryColor.opacity(0.8))
            
            // Item name with styling based on checked status
            Text(item.name)
                .font(.body)
                .foregroundColor(item.isChecked ? .secondary : .primary)
                // The crucial strikethrough effect
                .strikethrough(item.isChecked, color: .secondary)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Toggles the state when the row is tapped
            listManager.toggleItemChecked(item: item)
        }
    }
}
