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
    case glutenFree = "Gluten-Free"
    case peanutFree = "Peanut-Free"
    case dairyFree = "Dairy-Free"
    case sugarFree = "Sugar-Free"
    case treeNutFree = "Tree-Nut-Free"
    case alcoholFree = "Alcohol-Free"
    var id: String { self.rawValue }
}
