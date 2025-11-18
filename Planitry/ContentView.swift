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
    @StateObject private var listManager = GroceryListManager()
    
    // 1. New StateObject for Saved Recipes
    @StateObject private var recipeManager = RecipeManager()
    
    // State to control whether the splash screen is visible
    @State private var isLoading = true
    

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
                    
                    // 🔥 NEW TAB: My Recipes
                    RecipeView()
                        .tabItem {
                            Label("My Recipes", systemImage: "book.closed.fill")
                        }
                        .environmentObject(recipeManager)
                    
                    // Tab 5: Preferences (was Tab 4)
                    PreferencesView()
                        .tabItem {
                            Label("Preferences", systemImage: "gearshape.fill")
                        }
                }
                .accentColor(Color(red: 0.8, green: 0.2, blue: 0.1))
                .environmentObject(listManager)
                
                .fullScreenCover(isPresented: .constant(!settings.hasCompletedOnboarding)) {
                    OnboardingFlowView()
                        .environmentObject(settings)
                }
            }
        }
        .environmentObject(settings)
        .environmentObject(recipeManager)
        .environmentObject(inventoryManager)
        .environmentObject(listManager)
    }
}
