//
//  Untitled.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/27/25.
//
import SwiftUI
import Combine


struct GroceryListView: View {
    let accentColor = Color(red: 0.1, green: 0.1, blue: 0.8) // Blue accent

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "list.bullet.clipboard.fill")
                    .font(.system(size: 80))
                    .foregroundColor(accentColor)
                
                Text("Your Smart **Grocery List**")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("View required ingredients from planned meals, check off items as you shop, and easily merge multiple shopping trips into one.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Build a List (Coming Soon)") {
                    // Action placeholder
                }
                .padding()
                .background(accentColor.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Grocery List")
        }
    }
}
