//
//  MealModel.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import Foundation

// MARK: - API Data Models (A4)
// These structs define the structure for decoding the JSON response from the Edamam API.
// Use Codable to automatically map the JSON keys to Swift properties.

/// The top-level response container returned by the Edamam API.
struct EdamamResponse: Codable {
    let hits: [Hit]
}

/// The intermediate container for each recipe result.
/// The actual recipe data is nested one level deeper in the 'recipe' property.
struct Hit: Codable {
    let recipe: Meal
}

/// Only decode the necessary fields for the Alpha MVP.
struct Meal: Codable, Identifiable {
    // The full recipe name/title.
    let label: String
    
    // The URL for the meal's primary image.
    let image: String
    
    // The unique recipe ID
    var id: String { url }
    
    // The URL to the full recipe instructions on the source website.
    let url: String
    
    // The total calorie count
    let calories: Double
    
    // An array of health labels (e.g., "Keto", "Sugar-Free").
    let healthLabels: [String]
    
    // Use CodingKeys to map complex or incompatible JSON keys to clean Swift properties.
    enum CodingKeys: String, CodingKey {
        case label, image, url, calories, healthLabels
    }
}
