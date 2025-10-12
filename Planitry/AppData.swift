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
    case glutenFree = "Gluten Free"
    case peanutFree = "Peanut Free"
    case dairyFree = "Dairy Free"
    case sugarFree = "Sugar Free"
    case treeNutFree = "Tree Nut Free"
    case alcoholFree = "Alcohol Free"
    var id: String { self.rawValue }
}


// Error Enum for NetworkManager
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case noResultsFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL could not be constructed correctly."
        case .invalidResponse:
            return "The server returned an invalid response (non-200 status code)."
        case .decodingError(let error):
            // Provides more useful information for debugging decoding failures
            return "Failed to decode recipe data: \(error.localizedDescription)"
        case .noResultsFound:
            return "Your search criteria were too restrictive. No recipes were found."
        }
    }
}


