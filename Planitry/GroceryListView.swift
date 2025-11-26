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
            // Use ZStack to layer the content and the Floating Action Button
            ZStack(alignment: .bottomTrailing) {
                
                // Content Layer (The original VStack)
                // Set spacing to 0 for banner integration
                VStack(spacing: 0) {
                    
                    // 1. Custom Header REPLACED WITH BANNER
                    BannerView(
                        title: "Shopping List",
                        subtitle: "Plan meals and check off items" // Contextual subtitle
                    )
                    
                    // Wrap all the original content in a VStack with padding to create spacing below the banner
                    VStack(spacing: 5) {
                        
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
                        .padding(.top, 10) // Add padding to separate from the banner
                        .padding(.bottom, 10)
                        
                        // 3. Content Area
                        if listManager.groceryList.isEmpty {
                            ContentUnavailableView(
                                "Your Grocery List is Empty",
                                systemImage: "cart.fill",
                                description: Text("Add ingredients to start your persistent list.")
                            )
                            .foregroundColor(primaryColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Make ContentUnavailableView fill space
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
                    } // End Content VStack
                } // End Main VStack
                
                // 🔑 FLOATING ACTION BUTTON (FAB) for Clear All
                if !listManager.groceryList.isEmpty {
                    Button(action: {
                        // 🔑 Trigger alert
                        showingClearAllAlert = true
                    }) {
                        Image(systemName: "trash.fill") // A clear icon for deletion
                            .font(.title)
                            .padding(15)
                            .background(primaryColor) // Use the primary color for prominence
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 10, x: 5, y: 5) // Add a shadow for a floating effect
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            } // End ZStack
            
            // 4. Navigation Title/Bar Updates
            // Remove all toolbar items as requested (EditButton removed, Clear All is now FAB)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            
            // 🔑 ALERT MODIFIER remains attached to the NavigationView
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
