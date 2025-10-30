//
//  InventoryView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/27/25.
//
import SwiftUI
import Combine

struct InventoryView: View {
    @ObservedObject var manager: InventoryManager
    
    @State private var newIngredientName: String = ""
    @State private var newIngredientQuantity: String = ""
    @State private var newIngredientUnit: String = ""
    
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    // MARK: - Add/Delete Logic (Simplified to call manager)
    
    private func addIngredient() {
        guard let quantity = Double(newIngredientQuantity.trimmingCharacters(in: .whitespaces)),
              !newIngredientName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        manager.addIngredient(
            name: newIngredientName,
            quantity: quantity,
            unit: newIngredientUnit
        )
        
        // Reset fields
        newIngredientName = ""
        newIngredientQuantity = ""
        newIngredientUnit = ""
    }
    
    private func deleteIngredients(offsets: IndexSet) {
        manager.deleteIngredients(offsets: offsets)
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // MARK: - Header
                VStack(spacing: 8) {
                    Text("Pantry Inventory")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(primaryColor)
                        .padding(.top, 20)
                    
                    Text("Track what you have on hand to find the perfect recipe.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // MARK: - Add Ingredient Card
                VStack(alignment: .leading, spacing: 15) {
                    Text("ADD NEW INGREDIENT:")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Group {
                        TextField("Name (e.g., Chicken Breast)", text: $newIngredientName)
                            .padding(.vertical, 8)
                        
                        HStack {
                            TextField("Quantity (e.g., 2)", text: $newIngredientQuantity)
                                .keyboardType(.decimalPad)
                            
                            TextField("Unit (e.g., lbs, cups, unit)", text: $newIngredientUnit)
                        }
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Add Button
                    Button(action: addIngredient) {
                        Text("Add to Inventory")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryColor.opacity(newIngredientName.isEmpty ? 0.5 : 0.9))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(newIngredientName.isEmpty)
                    
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .shadow(radius: 3)
                .padding(.horizontal)
                
                // MARK: - Current Inventory List Card
                VStack(alignment: .leading) {
                    Text("YOUR CURRENT INVENTORY (\(manager.inventory.count))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                    
                    List {
                        // 🔑 Iterate over the manager's published array
                        ForEach(manager.inventory) { item in
                            HStack {
                                Text(item.name.capitalized)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(item.quantity, specifier: "%.1f") \(item.unit)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deleteIngredients)
                    }
                    .listStyle(.insetGrouped)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                // MARK: - Action Button
                if !manager.inventory.isEmpty {
                    // 🔑 Pass the manager to the next view
                    NavigationLink(destination: RecipeFinderView(manager: manager)) {
                        Text("Find Recipes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}
