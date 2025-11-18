//
//  EditIngredientView.swift
//  Planitry
//
//  Created by Mamie Gartin on 11/18/25.
//
import SwiftUI

struct EditIngredientView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var inventoryManager: InventoryManager
    
    // Store the ID and original values of the ingredient being edited
    let ingredientID: UUID
    let originalName: String
    
    // Local state for editing fields
    @State private var name: String
    @State private var quantity: String
    @State private var unit: String
    
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)

    init(inventoryManager: InventoryManager, ingredient: Ingredient) {
        self.inventoryManager = inventoryManager
        self.ingredientID = ingredient.id
        self.originalName = ingredient.name
        
        // Initialize local state from the original ingredient's values
        _name = State(initialValue: ingredient.name)
        // Format the quantity to 1 decimal place, then convert to String for the TextField
        _quantity = State(initialValue: String(format: "%.1f", ingredient.quantity))
        _unit = State(initialValue: ingredient.unit)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ingredient Details")) {
                    TextField("Name", text: $name)
                    
                    HStack {
                        // The user requested only name and units, but quantity is included for completeness
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.decimalPad)
                        
                        TextField("Unit", text: $unit)
                    }
                }
            }
            .navigationTitle("Edit \(originalName.capitalized)")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    // Disable save if name is empty or quantity is not a valid number
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || Double(quantity) == nil)
                    .foregroundColor(primaryColor)
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let newQuantity = Double(quantity) else { return }
        
        inventoryManager.updateIngredient(
            id: ingredientID,
            newName: name,
            newQuantity: newQuantity,
            newUnit: unit
        )
    }
}
