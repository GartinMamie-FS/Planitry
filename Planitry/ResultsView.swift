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
    
    // The view must receive a Meal object to display the results.
    let meal: Meal
    
    // This is the primary color for the buttons and accents
    let primaryColor = Color(red: 0.8, green: 0.1, blue: 0.1)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Meal Image (Mocked)
                // In the final version, this will load the image from the meal.image URL
                Image("placeholder_meal_image")
                    .resizable()
                    .scaledToFill()
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
                        Text("Total Calories:")
                            .fontWeight(.medium)
                        Text("\(Int(meal.calories)) kcal")
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                    }
                    .font(.title3)
                    
                    Divider()
                    
                    // Health Labels (Displaying mock data if available)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Health Labels:")
                            .font(.headline)
                        
                        // Displaying a selection of health labels
                        // In the future, this should iterate through meal.healthLabels
                        Text(meal.healthLabels.isEmpty ? "None specified" : meal.healthLabels.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // MARK: - Recipe Link Button
                    Button(action: {
                        // TODO: Implement external link opening (A8)
                        if let url = URL(string: meal.url) {
                            // Code to open the URL externally goes here (e.g., UIApplication.shared.open(url))
                            print("Opening recipe at: \(meal.url)")
                        }
                    }) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                            Text("View Full Recipe Instructions")
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

// MARK: - Placeholder Data for Testing
// This is necessary because the view requires a Meal object to compile.
struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResultsView(meal: Meal(
                label: "Spicy Tofu & Vegetable Stir-Fry",
                image: "https://yourplaceholder.com/image.jpg",
                url: "https://example.com/spicy-tofu-recipe",
                calories: 450.5,
                healthLabels: ["Vegan", "Gluten-Free", "Low-Sugar"] // Example data
            ))
        }
    }
}
