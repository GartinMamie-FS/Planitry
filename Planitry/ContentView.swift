//
//  ContentView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    // Instantiates the UserSettings model once and makes it available to the environment.
    @StateObject var settings = UserSettings()
    
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
                    
                    // Tab 2: Preferences
                    PreferencesView()
                        .tabItem {
                            Label("Preferences", systemImage: "gearshape.fill")
                        }
                }
                .accentColor(Color(red: 0.8, green: 0.2, blue: 0.1))
                
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
