//
//  Untitled.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/27/25.
//
import SwiftUI
import Combine


struct GroceryListView: View {
    
    @EnvironmentObject var listManager: GroceryListManager
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    // Computed properties to split the list for better shopping experience
    var remainingItems: [GroceryListItem] {
        listManager.groceryList.filter { !$0.isChecked }
    }
    
    var checkedItems: [GroceryListItem] {
        listManager.groceryList.filter { $0.isChecked }
    }
    
    // State for the new item text field
    @State private var newItemName: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // 1. Custom Header
                VStack(spacing: 5) {
                    Text("Your Shopping List")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(primaryColor)
                        .padding(.top, 20)
                    
                    Text("Ingredients needed for your generated meals.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                }
                .padding(.horizontal)
                
                // 2. Add Item Section
                HStack {
                    TextField("Add new item...", text: $newItemName)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .submitLabel(.done)
                    
                    Button {
                        if !newItemName.isEmpty {
                            listManager.addItem(ingredientName: newItemName)
                            newItemName = ""
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(primaryColor)
                    }
                    .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // 3. Content Area
                if listManager.groceryList.isEmpty {
                    ContentUnavailableView(
                        "Your Grocery List is Empty",
                        systemImage: "cart.fill",
                        description: Text("Add ingredients to start your persistent list.")
                    )
                    .foregroundColor(primaryColor)
                } else {
                    List {
                        // Section 1: Remaining Items
                        if !remainingItems.isEmpty {
                            Section("Remaining (\(remainingItems.count))") {
                                ForEach(remainingItems) { item in
                                    ShoppingListItemRow(item: item, listManager: listManager, primaryColor: primaryColor)
                                }
                                .onDelete(perform: deleteRemainingItems)
                            }
                            .headerProminence(.increased)
                        }
                        
                        // Section 2: Checked Items
                        if !checkedItems.isEmpty {
                            Section("Checked (\(checkedItems.count))") {
                                ForEach(checkedItems) { item in
                                    ShoppingListItemRow(item: item, listManager: listManager, primaryColor: primaryColor)
                                }
                                // Allow deletion of checked items
                                .onDelete(perform: deleteCheckedItems)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            
            // 4. Navigation Title/Bar Updates
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All", role: .destructive) {
                        listManager.clearList()
                    }
                    .disabled(listManager.groceryList.isEmpty)
                    .foregroundColor(primaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundColor(primaryColor)
                }
            }
        }
    }
    
    // Helper function to correctly delete items from the original groceryList when viewing the filtered checkedItems
    func deleteCheckedItems(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = checkedItems[index]
            listManager.removeItem(item: itemToDelete)
        }
    }
    
    // Helper function to correctly delete items from the original groceryList when viewing the filtered remainingItems
    func deleteRemainingItems(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = remainingItems[index]
            listManager.removeItem(item: itemToDelete)
        }
    }
}

