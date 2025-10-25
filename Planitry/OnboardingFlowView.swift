//
//  OnboardingFlowView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/25/25.
//
import SwiftUI

struct OnboardingItem: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
    let accentColor: Color
}


// MARK: - 1. Main Flow Container View

struct OnboardingFlowView: View {
    
    @EnvironmentObject var settings: UserSettings
    
    @State private var currentPageIndex = 0
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            // The flow only presents the OnboardingView
            OnboardingView(
                currentPageIndex: $currentPageIndex,
                onSkipOrComplete: {
                    settings.hasCompletedOnboarding = true
                    // Apply defaults, even if skipping, to ensure clean state
                    settings.applyDefaultPreferences()
                    dismiss()
                }
            )
            .transition(.move(edge: .leading))
            
        }
    }
}


// MARK: - 2. Onboarding Slides View

struct OnboardingView: View {
    let pages: [OnboardingItem] = [
        OnboardingItem(
            iconName: "slider.horizontal.3",
            title: "Your Personalized Plate",
            description: "We start with balanced defaults, but you can change your diet, calorie goals, and constraints anytime in settings.",
            accentColor: Color(red: 0.1, green: 0.4, blue: 0.7)
        ),
        OnboardingItem(
            iconName: "flame.fill",
            title: "Discover New Recipes",
            description: "Explore a curated library of delicious recipes tailored to your dietary needs and preferences.",
            accentColor: Color(red: 0.9, green: 0.6, blue: 0.1)
        ),
        OnboardingItem(
            iconName: "cart.fill",
            title: "Smart Grocery Lists",
            description: "Automatically generate shopping lists from your meal plan and share them with your family.",
            accentColor: Color(red: 0.3, green: 0.6, blue: 0.3)
        )
    ]
    
    @Binding var currentPageIndex: Int
    let onSkipOrComplete: () -> Void

    var body: some View {
        VStack {
            
            // Skip Button
            HStack {
                Spacer()
                Button("Skip") {
                    onSkipOrComplete()
                }
                .padding(.top, 20)
                .padding(.horizontal, 30)
                .foregroundColor(.gray)
            }
            
            // TabView for swipeable pages
            TabView(selection: $currentPageIndex) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPage(item: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
            // Page Indicator (Dots)
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Circle()
                        .fill(index == currentPageIndex ? pages[index].accentColor : Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                        .animation(.easeInOut, value: currentPageIndex)
                }
            }
            .padding(.vertical, 10)
            
            // Dynamic Navigation Button
            Button(action: {
                if currentPageIndex == pages.count - 1 {
                    // Final button now calls the completion action directly
                    onSkipOrComplete()
                } else {
                    withAnimation {
                        currentPageIndex += 1
                    }
                }
            }) {
                Text(getButtonText())
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(pages[currentPageIndex].accentColor)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
    
    func getButtonText() -> String {
        if currentPageIndex < pages.count - 1 {
            return "Next Feature"
        } else {
            // New, final action text
            return "Start Cooking"
        }
    }
}

// Reusable Component for a Single Onboarding Page (UNCHANGED)
struct OnboardingPage: View {
    let item: OnboardingItem
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: item.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(item.accentColor)
                .padding(.bottom, 30)
                .symbolRenderingMode(.palette)
                .shadow(radius: 10)

            Text(item.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(item.description)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Root View for Preview/Testing (UNCHANGED)
struct OnboardingRootView: View {
    @StateObject var settings = UserSettings()
    
    var body: some View {
        if !settings.hasCompletedOnboarding {
            OnboardingFlowView()
                .environmentObject(settings)
        } else {
            // Placeholder for the main app view
            VStack(spacing: 20) {
                Text("Welcome to the Main App!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.3))
                    .padding(.top, 50)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Saved Preferences:")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text("Diet: \(settings.selectedDiet.capitalized)")
                    Text("Max Calories: \(settings.maxCalories) kcal")
                    Text("Constraints:")
                    Text(settings.activeHealthConstraintsString.isEmpty ? "None" : settings.activeHealthConstraintsString.replacingOccurrences(of: ",", with: ", ").capitalized)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                Button("Reset Onboarding") {
                    settings.hasCompletedOnboarding = false
                    settings.applyDefaultPreferences()
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
}
