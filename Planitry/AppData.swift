//
//  AppData.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/7/25.
//

import Foundation

// MARK: - App Data Structures (Used by Planner and Preferences)

// Define all possible meal types for the Picker in A7
enum MealType: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    var id: String { self.rawValue }
}

// Define possible health constraints (for Toggles in A3)
enum HealthConstraint: String, CaseIterable, Identifiable {
    // UI Display Names
    case glutenFree = "Gluten Free"
    case peanutFree = "Peanut Free"
    case dairyFree = "Dairy Free"
    case sugarFree = "Sugar Free"
    case treeNutFree = "Tree Nut Free"
    case alcoholFree = "Alcohol Free"
    
    var id: String { self.rawValue }
    
    // CRITICAL: Computed property for the API-compatible value
    var apiValue: String {
        switch self {
        case .glutenFree: return "gluten-free"
        case .peanutFree: return "peanut-free"
        case .dairyFree: return "dairy-free"
        case .sugarFree: return "sugar-conscious" // Edamam standard for sugar restrictions
        case .treeNutFree: return "tree-nut-free"
        case .alcoholFree: return "alcohol-free"
        }
    }
}


// Error Enum for NetworkManager
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse(Int?) // <-- NOW CAPTURES THE HTTP STATUS CODE
    case decodingError(Error)
    case noResultsFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL could not be constructed correctly."
        case .invalidResponse(let statusCode):
            if let code = statusCode {
                 return "The server returned an error (Status Code: \(code)). This often means invalid API keys or a problematic query."
            } else {
                 return "The server returned an invalid response."
            }
        case .decodingError(let error):
            // Provides more useful information for debugging decoding failures
            return "Failed to decode recipe data: \(error.localizedDescription)"
        case .noResultsFound:
            return "Your search criteria were too restrictive. No recipes were found."
        }
    }
}

struct Ingredient: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    var quantity: Double
    var unit: String
    let dateAdded = Date()
    
    // Helper for normalizing the ingredient name for duplicate checking
    var normalizedName: String {
        name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct NutrientModel: Decodable {
    let label: String
    let quantity: Double
    let unit: String
}
