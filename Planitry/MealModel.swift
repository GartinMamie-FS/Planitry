//
//  MealModel.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/12/25.
//

import Foundation

// MARK: - 1. MODEL DEFINITIONS

struct MealModel: Decodable, Identifiable {
    let id: String
    let label: String
    let imageUrl: String
    let url: String
    let source: String
    let yield: Double
    let calories: Double
    let mealType: [String]?
    let dietLabels: [String]?
    let healthLabels: [String]?
    let ingredients: [String]
    
    // PROPERTIES RE-ADDED: Required by ResultsView in previous iterations
    let totalTime: Double
    
    // Computed property for easy access
    var ingredientCount: Int {
        return ingredients.count
    }
    
    var calculatedCalories: Int {
        // If yield is 0, return the total calories, otherwise calculate per serving
        if yield > 0 {
            return Int((calories / yield).rounded())
        }
        return Int(calories.rounded())
    }
    
    
    enum CodingKeys: String, CodingKey {
        case label, url, yield, calories, mealType, dietLabels, healthLabels, source, totalTime, totalNutrients // Added totalTime, totalNutrients
        case uri
        case image = "image"
        case ingredientLines = "ingredientLines"
    }
    
    // FIX 1: CUSTOM CONVENIENCE INITIALIZER (To fix the error in performRecipeSearch)
    // This initializer is manually added back so the dummy data creation works.
    init(id: String, label: String, imageUrl: String, url: String, source: String, yield: Double, calories: Double, mealType: [String], dietLabels: [String], healthLabels: [String], ingredients: [String], totalTime: Double, totalNutrients: [String: NutrientModel]) {
        self.id = id
        self.label = label
        self.imageUrl = imageUrl
        self.url = url
        self.source = source
        self.yield = yield
        self.calories = calories
        self.mealType = mealType
        self.dietLabels = dietLabels
        self.healthLabels = healthLabels
        self.ingredients = ingredients
        self.totalTime = totalTime
    }
    
    // Custom initializer to handle API structure and ID/Renaming (The Decodable required init)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.label = try container.decode(String.self, forKey: .label)
        self.imageUrl = try container.decode(String.self, forKey: .image)
        self.url = try container.decode(String.self, forKey: .url)
        self.source = try container.decode(String.self, forKey: .source)
        self.yield = try container.decode(Double.self, forKey: .yield)
        self.calories = try container.decode(Double.self, forKey: .calories)
        self.mealType = try container.decodeIfPresent([String].self, forKey: .mealType)
        self.dietLabels = try container.decodeIfPresent([String].self, forKey: .dietLabels)
        self.healthLabels = try container.decodeIfPresent([String].self, forKey: .healthLabels)

        self.ingredients = try container.decode([String].self, forKey: .ingredientLines)
        
        // Decoding re-added properties
        self.totalTime = try container.decode(Double.self, forKey: .totalTime)


        // The 'id' is extracted from the 'uri'
        let uri = try container.decode(String.self, forKey: .uri)
        if let idFragment = uri.split(separator: "_").last {
            self.id = String(idFragment)
        } else {
            self.id = UUID().uuidString
        }
    }
}

// Struct to hold constraints for the API call
struct MealConstraints {
    let mealType: String
    let maxCalories: Int
    let healthConstraints: [String]
    
    // Enum defining all user-selectable diet constraints (both Edamam 'diet' and 'health' types)
    enum DietOption: String, CaseIterable, Identifiable {
        case balanced = "Balanced (Default)"
        
        // Official Edamam &diet= parameters
        case lowCarb = "Low-Carb"
        case highProtein = "High-Protein"
        case lowFat = "Low-Fat"
        case lowSodium = "Low-Sodium"
        case highFiber = "High-Fiber"
        
        // Popular diets / Health Labels (these map to &health= internally in NetworkManager)
        case keto = "Keto-Friendly"
        case vegan = "Vegan"
        case vegetarian = "Vegetarian"
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        
        var id: String { self.rawValue }
        
        // Helper property to get the API-compatible *internal* value used by NetworkManager for splitting.
        var apiValue: String {
            switch self {
            case .lowCarb: return "low-carb"
            case .highProtein: return "high-protein"
            case .lowFat: return "low-fat"
            case .lowSodium: return "low-sodium"
            case .highFiber: return "high-fiber"
                
            // These values are simple strings used as keys for the mapping dictionary in NetworkManager
            case .keto: return "keto"
            case .vegan: return "vegan"
            case .vegetarian: return "vegetarian"
            case .glutenFree: return "gluten-free"
            case .dairyFree: return "dairy-free"
            case .balanced: return "balanced"
            }
        }
    }
}
