//
//  ContentView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

// MARK: - ContentView
import SwiftUI
import Combine

struct ContentView: View {
    // Managers must be declared first
    @StateObject var settings: UserSettings
    @StateObject private var inventoryManager: InventoryManager
    @StateObject private var listManager: GroceryListManager
    @StateObject private var recipeManager: RecipeManager
    
    // State to control whether the landing page is visible
    @State private var showLandingPage = true // Changed to control landing page

    // MARK: - Custom Initializer for Manager Linking
    init() {
        // 1. Initialize core managers
        let settings = UserSettings()
        let inventory = InventoryManager()
        let recipe = RecipeManager()
        
        // 2. Initialize GroceryListManager, passing the InventoryManager's method as the handler
        let groceryList = GroceryListManager(
            inventoryTransferHandler: inventory.receivePurchasedItem
        )
        
        // 3. Assign managers to @StateObject properties
        self._settings = StateObject(wrappedValue: settings)
        self._inventoryManager = StateObject(wrappedValue: inventory)
        self._recipeManager = StateObject(wrappedValue: recipe)
        self._listManager = StateObject(wrappedValue: groceryList)
    }

    // MARK: - View Body
    var body: some View {
        
        ZStack {
            // Conditional View Rendering: Show LandingPageView OR TabView
            if showLandingPage {
                LandingPageView(showLandingPage: $showLandingPage) // Pass the binding
            } else {
                // If landing page is dismissed, show the main TabView
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
                    
                    // Tab 3: Grocery List
                    GroceryListView()
                        .tabItem {
                            Label("Grocery List", systemImage: "list.bullet.clipboard.fill")
                        }
                    
                    // Tab 4: My Recipes
                    RecipeView()
                        .tabItem {
                            Label("My Recipes", systemImage: "book.closed.fill")
                        }
                    
                    // Tab 5: Preferences
                    PreferencesView()
                        .tabItem {
                            Label("Preferences", systemImage: "gearshape.fill")
                        }
                }
                .accentColor(Color(red: 0.8, green: 0.2, blue: 0.1))
                
                .fullScreenCover(isPresented: .constant(!settings.hasCompletedOnboarding)) {
                    OnboardingFlowView()
                        .environmentObject(settings)
                }
            }
        }
        // Set all environment objects at the highest level for all tabs
        .environmentObject(settings)
        .environmentObject(inventoryManager)
        .environmentObject(listManager)
        .environmentObject(recipeManager)
    }
}
