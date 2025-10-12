//
//  ResultsView.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import SwiftUI


// MARK: - Results View (A8)

// This view displays the details of the single generated meal.
struct ResultsView: View {
    
    @Environment(\.openURL) var openURL
    
    let meal: MealModel
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Meal Image
                AsyncImage(url: URL(string: meal.imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        Image(systemName: "photo.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .frame(height: 250)
                    }
                }
                .frame(height: 250)
                .clipped()
                
                // MARK: - Meal Details Card
                VStack(alignment: .leading, spacing: 15) {
                    
                    // Meal Name
                    Text(meal.label)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                    
                    // Calorie Count
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Calories Per Serving:")
                            .fontWeight(.medium)
                        Text("\(meal.calculatedCalories) kcal")
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                    }
                    .font(.title3)
                    
                    Text("Yields: \(Int(meal.yield)) servings (Total Recipe Calories: \(Int(meal.calories.rounded())) kcal)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    // MARK: - Ingredients List
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ingredients (\(meal.ingredientCount)):")
                            .font(.headline)
                        
                        // Display the list of ingredients
                        ForEach(meal.ingredients, id: \.self) { ingredient in
                            HStack(alignment: .top) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(primaryColor)
                                    .padding(.top, 5)
                                Text(ingredient)
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    
                    Divider()
                    
                    // MARK: - Recipe Link Button
                    Button(action: {
                        if let url = URL(string: meal.url) {
                            openURL(url)
                            print("Attempting to open recipe at: \(meal.url)")
                        }
                    }) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                            Text("View Full Recipe Instructions from \(meal.source)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                }
                .padding()
                
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationTitle("Your Meal Idea")
        .navigationBarTitleDisplayMode(.inline)
    }
}
