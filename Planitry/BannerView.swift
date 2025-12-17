//
//  BannerView.swift
//  Planitry
//
//  Created by Mamie Gartin on 11/26/25.
//
import SwiftUI

struct BannerView: View {
    let title: String
    let subtitle: String?
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1) // Your app's primary red
    
    // New desired height
    let bannerHeight: CGFloat = 120

    var body: some View {
        ZStack {
            // 1. Background Image
            Image("splash")
                .resizable()
                .aspectRatio(contentMode: .fill) // Fill the banner area
                .frame(height: bannerHeight) // Updated frame height
                .clipped()

            // 2. Semi-transparent Overlay for better text legibility
            Rectangle()
                .fill(Color.black.opacity(0.4))
                .frame(height: bannerHeight)

            // 3. Foreground Content (Title and Subtitle)
            VStack {

                // Main App Title
                Text(title)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                
                // Optional Subtitle/Context
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
            }
        }
        .frame(maxWidth: .infinity) 
    }
}
