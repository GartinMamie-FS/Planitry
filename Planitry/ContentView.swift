//
//  ContentView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var settings = UserSettings()
    @StateObject private var inventoryManager = InventoryManager()
    
        
    
    // State to control whether the splash screen is visible
    @State private var isLoading = true
    
    @State private var inventory: [Ingredient] = [
            Ingredient(name: "milk", quantity: 1, unit: "cup"),
            Ingredient(name: "butter", quantity: 0.5, unit: "stick"),
            Ingredient(name: "sugar", quantity: 2, unit: "tbsp")
        ]
    @StateObject var listManager = GroceryListManager()
    
    // Custom Initializer to set up the managers and link them
        init() {
            // 1. Initialize InventoryManager
            let inventory = InventoryManager()
            self._inventoryManager = StateObject(wrappedValue: inventory)

            // 2. Initialize GroceryListManager, passing the InventoryManager's purchase handler
            // This creates the link for automatic transfer
            let groceryList = GroceryListManager(inventoryTransferHandler: inventory.receivePurchasedItem)
            self._listManager = StateObject(wrappedValue: groceryList)

            // 3. Initialize other StateObjects
            self._settings = StateObject(wrappedValue: UserSettings())
            self._isLoading = State(initialValue: true)
        }
    
    var body: some View {
        
        ZStack {
            // Conditional View Rendering: Show SplashView OR TabView
            if isLoading {
                SplashView()
                    .onAppear {
                        // Use DispatchQueue to simulate network call latency
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                self.isLoading = false // Hide splash screen
                            }
                        }
                    }
            } else {
                // If loading is complete, show the main TabView
                TabView {
                    // Tab 1: Planner
                    PlannerView()
                        .tabItem {
                            Label("Planner", systemImage: "fork.knife")
                        }

                    // Tab 2: Inventory
                    InventoryView()
                        .tabItem {
                            Label("Inventory", systemImage: "archivebox.fill")
                        }
                        .environmentObject(inventoryManager)
                    
                    // Tab 3: Grocery List
                    GroceryListView()
                        .tabItem {
                            Label("Grocery List", systemImage: "list.bullet.clipboard.fill")
                        }
                    
                    
                    // Tab 4: Preferences
                    PreferencesView()
                        .tabItem {
                            Label("Preferences", systemImage: "gearshape.fill")
                        }
                }
                .accentColor(Color(red: 0.8, green: 0.2, blue: 0.1))
                .environmentObject(listManager)
                
                .fullScreenCover(isPresented: .constant(!settings.hasCompletedOnboarding)) {
                    OnboardingFlowView()
                        // Ensure the UserSettings object is available inside the modal
                        .environmentObject(settings)
                }
            }
        }
        .environmentObject(settings)
    }
}
