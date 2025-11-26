//
//  LandingPageView.swift
//  Planitry
//
//  Created by Mamie Gartin on 11/26/25.
//

import SwiftUI

// MARK: - SplashView (now LandingPageView)
struct LandingPageView: View {
    @Binding var showLandingPage: Bool // Binding to control visibility

    var body: some View {
        ZStack {
            // 1. Background Image (assuming "splash" is in your assets)
            Image("splash")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            // 2. Semi-transparent overlay for text legibility
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // 3. Foreground Content (Logo, Title, and Go Button)
            VStack {
                Spacer() // Pushes content towards the center/top

                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)

                Text("Planitry")
                    .font(.system(size: 50, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 8)

                Text("Your Meal Planning Companion")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                
                Spacer() // Pushes button towards the bottom

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showLandingPage = false // Dismiss the landing page
                    }
                }) {
                    Text("Go")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 80)
                        .background(Color.red) // Red button background
                        .cornerRadius(30)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 50) // Adjust padding from bottom
            }
        }
    }
}

