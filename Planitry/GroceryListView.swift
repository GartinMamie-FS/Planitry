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
    
    // State for collapsible sections
    @State private var isRemainingExpanded: Bool = true
    @State private var isCheckedExpanded: Bool = false
    
    // 🔑 NEW STATE FOR CLEAR ALL CONFIRMATION ALERT
    @State private var showingClearAllAlert = false
    
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
                        // Section 1: Remaining Items (Collapsible)
                        if !remainingItems.isEmpty {
                            Section {
                                // Only show content if expanded
                                if isRemainingExpanded {
                                    ForEach(remainingItems) { item in
                                        ShoppingListItemRow(item: item, listManager: listManager, primaryColor: primaryColor)
                                    }
                                    .onDelete(perform: deleteRemainingItems)
                                }
                            } header: {
                                // Custom tappable header to toggle the state
                                HStack {
                                    Text("Remaining (\(remainingItems.count))")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Image(systemName: isRemainingExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.secondary)
                                }
                                .contentShape(Rectangle()) // Makes the entire HStack tappable
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isRemainingExpanded.toggle()
                                    }
                                }
                            }
                            .headerProminence(.increased)
                        }
                        
                        // Section 2: Checked Items (Collapsible)
                        if !checkedItems.isEmpty {
                            Section {
                                // Only show content if expanded
                                if isCheckedExpanded {
                                    ForEach(checkedItems) { item in
                                        ShoppingListItemRow(item: item, listManager: listManager, primaryColor: primaryColor)
                                    }
                                    // Allow deletion of checked items
                                    .onDelete(perform: deleteCheckedItems)
                                }
                            } header: {
                                // Custom tappable header to toggle the state
                                HStack {
                                    Text("Checked (\(checkedItems.count))")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Image(systemName: isCheckedExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.secondary)
                                }
                                .contentShape(Rectangle()) // Makes the entire HStack tappable
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isCheckedExpanded.toggle()
                                    }
                                }
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
                        // 🔑 Trigger alert instead of clearing immediately
                        showingClearAllAlert = true
                    }
                    .disabled(listManager.groceryList.isEmpty)
                    .foregroundColor(primaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundColor(primaryColor)
                }
            }
            // 🔑 ALERT MODIFIER
            .alert("Confirm Clear List", isPresented: $showingClearAllAlert) {
                Button("Clear List", role: .destructive) {
                    listManager.clearList()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to permanently delete all items from your grocery list? This action cannot be undone.")
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
