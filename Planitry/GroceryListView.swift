//
//  Untitled.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/27/25.
//
import SwiftUI
import Combine
import AVFoundation


// MARK: - Haptic Helper
// Helper for quick, standard vibration feedback
struct HapticHelper {
    static func generateSuccess() {
        // Requires UIKit import (already present)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}


struct GroceryListView: View {
    
    @EnvironmentObject var listManager: GroceryListManager
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    // Computed properties (FIXED)
    var remainingItems: [GroceryListItem] {
        // CORRECT: Filter for unchecked items
        listManager.groceryList.filter { !$0.isChecked }
    }
    
    var checkedItems: [GroceryListItem] {
        // CORRECT: Filter for checked items (The bug fix)
        listManager.groceryList.filter { $0.isChecked }
    }
    
    // State for the new item text field
    @State private var newItemName: String = ""
    
    // State for collapsible sections
    @State private var isRemainingExpanded: Bool = true
    @State private var isCheckedExpanded: Bool = false
    
    // State for clear all confirmation alert
    @State private var showingClearAllAlert = false
    
    // State for visual feedback/animation on the Add button
    @State private var isAdding: Bool = false
    
    // State for the shake animation on the input field
    @State private var shakeOffset: CGFloat = 0

    // MARK: - Action Functions
    
    private func addNewItem() {
        guard !newItemName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        // 1. Play Feedback (Haptics & Sound)
        HapticHelper.generateSuccess()
        AudioPlayerHelperC.playSound(named: "check", withExtension: "mp3")

        // 2. Trigger Visual Animation (Scale and Rotation)
        withAnimation(.easeOut(duration: 0.1)) {
            isAdding = true
        }

        // 3. Trigger Shake Animation (Wiggle)
        withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.2, blendDuration: 0.2)) {
            shakeOffset = -10 // Start shake left
        }
        
        // 4. Add Item to Manager
        listManager.addItem(ingredientName: newItemName)
        newItemName = ""

        // 5. Reset Animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.2, blendDuration: 0.2)) {
                shakeOffset = 0 // Finish shake in center
            }
            withAnimation(.easeIn(duration: 0.2)) {
                isAdding = false // Reset scale/rotation
            }
        }
    }
    
    // Helper function to correctly delete items from the checked section
    func deleteCheckedItems(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = checkedItems[index]
            listManager.removeItem(item: itemToDelete)
        }
    }
    
    // Helper function to correctly delete items from the remaining section
    func deleteRemainingItems(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = remainingItems[index]
            listManager.removeItem(item: itemToDelete)
        }
    }

    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    
                    // 1. Custom Header
                    BannerView(
                        title: "Shopping List",
                        subtitle: "Plan meals and check off items"
                    )
                    
                    VStack(spacing: 5) {
                        
                        // 2. Add Item Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ADD NEW GROCERY ITEM:")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding(.leading, 5)

                            HStack {
                                TextField("Add new item...", text: $newItemName)
                                    .padding(5)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .submitLabel(.done)
                                    .onSubmit(addNewItem)
                                
                                // UPDATED ADD BUTTON WITH ANIMATIONS
                                Button(action: addNewItem) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                        .foregroundColor(primaryColor)
                                        // Scale and Rotation
                                        .scaleEffect(isAdding ? 1.2 : 1.0)
                                        .rotationEffect(.degrees(isAdding ? 90 : 0))
                                }
                                .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal, 5)
                            // Apply Shake Animation to the input block
                            .offset(x: shakeOffset)
                            
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .padding(.horizontal)
                        
                        // 3. Content Area
                        if listManager.groceryList.isEmpty {
                            ContentUnavailableView(
                                "Your Grocery List is Empty",
                                systemImage: "cart.fill",
                                description: Text("Add ingredients to start your persistent list.")
                            )
                            .foregroundColor(primaryColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List {
                                // Remaining Items Section
                                if !remainingItems.isEmpty {
                                    Section {
                                        if isRemainingExpanded {
                                            ForEach(remainingItems) { item in
                                                // Assuming ShoppingListItemRow handles the toggling action correctly
                                                ShoppingListItemRow(item: item, listManager: listManager, primaryColor: primaryColor)
                                            }
                                            .onDelete(perform: deleteRemainingItems)
                                        }
                                    } header: {
                                        HStack {
                                            Text("Remaining (\(remainingItems.count))")
                                                .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                                            Spacer()
                                            Image(systemName: isRemainingExpanded ? "chevron.up" : "chevron.down")
                                                .foregroundColor(.secondary)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { isRemainingExpanded.toggle() } }
                                    }
                                    .headerProminence(.increased)
                                }
                                
                                // Checked Items Section
                                if !checkedItems.isEmpty {
                                    Section {
                                        if isCheckedExpanded {
                                            ForEach(checkedItems) { item in
                                                // Assuming ShoppingListItemRow handles the toggling action correctly
                                                ShoppingListItemRow(item: item, listManager: listManager, primaryColor: primaryColor)
                                            }
                                            .onDelete(perform: deleteCheckedItems)
                                        }
                                    } header: {
                                        HStack {
                                            Text("Checked (\(checkedItems.count))")
                                                .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                                            Spacer()
                                            Image(systemName: isCheckedExpanded ? "chevron.up" : "chevron.down")
                                                .foregroundColor(.secondary)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { isCheckedExpanded.toggle() } }
                                    }
                                }
                            }
                            .listStyle(.insetGrouped)
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
                
                // FLOATING ACTION BUTTON (FAB) for Clear All
                if !listManager.groceryList.isEmpty {
                    Button(action: {
                        showingClearAllAlert = true
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.title)
                            .padding(15)
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 10, x: 5, y: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            
            // ALERT MODIFIER
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
}
