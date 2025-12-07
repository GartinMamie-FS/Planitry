//
//  ContentView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI
import Combine
import AVFoundation // 1. Import AVFoundation

// MARK: - Tab Selection Enumeration
// Define an enum to clearly represent each tab.
enum TabSelection: Hashable {
    case planner, inventory, groceryList, recipes, preferences
}

// MARK: - Audio Helper (AVFoundation)
// A simple struct to handle playing a single sound
struct AudioPlayerHelperC {
    private static var audioPlayer: AVAudioPlayer?
    
    // Function to load and play a sound from the main bundle
    static func playSound(named soundName: String, withExtension ext: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: ext) else {
            print("Sound file \(soundName).\(ext) not found.")
            return
        }

        do {
            // Re-initialize the player on each play to ensure sound plays fully, even if triggered quickly
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not load or play audio file: \(error)")
        }
    }
}


// MARK: - ContentView
struct ContentView: View {
    
    // Managers must be declared first
    @StateObject var settings: UserSettings
    @StateObject private var inventoryManager: InventoryManager
    @StateObject private var listManager: GroceryListManager
    @StateObject private var recipeManager: RecipeManager
    
    // State to control whether the landing page is visible
    @State private var showLandingPage = true
    
    // 2. State to track the currently selected tab
    @State private var selectedTab: TabSelection = .planner

    // MARK: - Custom Initializer (Unchanged)
    init() {
        // ... (Initialization remains the same)
        let settings = UserSettings()
        let inventory = InventoryManager()
        let recipe = RecipeManager()
        
        let groceryList = GroceryListManager(
            inventoryTransferHandler: inventory.receivePurchasedItem
        )
        
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
                LandingPageView(showLandingPage: $showLandingPage)
            } else {
                // Main TabView
                TabView(selection: $selectedTab) { // 3. Bind the TabView to the selection state
                    
                    // Tab 1: Planner
                    PlannerView()
                        .tabItem {
                            Label("Planner", systemImage: "fork.knife")
                        }
                        .tag(TabSelection.planner) // Assign a tag corresponding to the enum

                    // Tab 2: Inventory
                    InventoryView()
                        .tabItem {
                            Label("Inventory", systemImage: "archivebox.fill")
                        }
                        .tag(TabSelection.inventory)
                    
                    // Tab 3: Grocery List
                    GroceryListView()
                        .tabItem {
                            Label("Grocery List", systemImage: "list.bullet.clipboard.fill")
                        }
                        .tag(TabSelection.groceryList)
                    
                    // Tab 4: My Recipes
                    RecipeView()
                        .tabItem {
                            Label("My Recipes", systemImage: "book.closed.fill")
                        }
                        .tag(TabSelection.recipes)
                    
                    // Tab 5: Preferences
                    PreferencesView()
                        .tabItem {
                            Label("Preferences", systemImage: "gearshape.fill")
                        }
                        .tag(TabSelection.preferences)
                }
                .accentColor(Color(red: 0.8, green: 0.2, blue: 0.1))
                
                // 4. Attach onChange modifier to the TabView
                .onChange(of: selectedTab) { oldValue, newValue in
                    // Play the sound effect whenever the tab changes
                    AudioPlayerHelperC.playSound(named: "swosh", withExtension: "mp3")
                }
                
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
