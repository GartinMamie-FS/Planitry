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
    
    // NEW: Computed properties to split the list for better shopping experience
    var remainingItems: [GroceryListItem] {
        listManager.groceryList.filter { !$0.isChecked }
    }
    
    var checkedItems: [GroceryListItem] {
        listManager.groceryList.filter { $0.isChecked }
    }

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
                
                // 2. Content Area
                if listManager.groceryList.isEmpty {
                    ContentUnavailableView(
                        "Your Grocery List is Empty",
                        systemImage: "cart.fill",
                        description: Text("Add ingredients from a generated meal to start your list.")
                    )
                    .foregroundColor(primaryColor)
                } else {
                    List {
                        // Section 1: Remaining Items (High Priority)
                        if !remainingItems.isEmpty {
                            Section("Remaining (\(remainingItems.count))") {
                                ForEach(remainingItems) { item in
                                    ShoppingListItemRow(item: item, listManager: listManager, primaryColor: primaryColor)
                                }
                                // Deletion is disabled here to encourage checking off, but can be enabled if desired
                                //.onDelete { offsets in listManager.removeItem(at: offsets) }
                            }
                            .headerProminence(.increased)
                        }

                        // Section 2: Checked Items (Low Priority)
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
            
            // 3. Navigation Title/Bar Updates
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
            listManager.groceryList.removeAll { $0.id == itemToDelete.id }
        }
    }
}

// MARK: - Individual Item Row (NEW)

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
        .contentShape(Rectangle()) // Makes the entire row tappable
        .onTapGesture {
            // Toggles the state when the row is tapped
            listManager.toggleItemChecked(item: item)
        }
    }
}

