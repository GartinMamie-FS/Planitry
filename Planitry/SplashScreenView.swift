//
//  SplashScreenView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/25/25.
//

import SwiftUI

struct SplashView: View {
    
    var body: some View {
        ZStack {
            
            // 1. Background Image
            Image("splash")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // 2. Semi-transparent overlay for text legibility
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // 3. Foreground Content (Logo, Title, and Loader)
            VStack {
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
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding(.top, 40)
            }
        }
    }
}
