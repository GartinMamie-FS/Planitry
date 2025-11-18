//
//  MealModel.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/12/25.
//

import Foundation

// MARK: - 1. MODEL DEFINITIONS

struct MealModel: Codable, Identifiable {
    
    // MARK: - Required for Identifiable & Persistence
    let id: String
    let label: String
    
    // MARK: - Recipe Details
    let imageUrl: String
    let url: String
    let source: String
    
    // MARK: - Nutritional & Yield
    let yield: Double
    let calories: Double
    let totalTime: Double
    
    // MARK: - Labels & Ingredients
    let mealType: [String]?
    let dietLabels: [String]?
    let healthLabels: [String]?
    let ingredients: [String]
    let ingredientNames: [String] // The clean names for the shopping list
    
    // Computed properties
    var ingredientCount: Int {
        return ingredients.count
    }
    
    var calculatedCalories: Int {
        if yield > 0 {
            return Int((calories / yield).rounded())
        }
        return Int(calories.rounded())
    }
    
    // MARK: - SwiftUI View Helpers
    var name: String { label }
    var caloriesInt: Int { calculatedCalories }
    var totalTimeMinutes: Int { Int(totalTime) }
    var image: String { imageUrl }
    var tags: [String] {
        return (healthLabels?.prefix(2).map { $0.capitalized } ?? dietLabels?.prefix(2).map { $0.capitalized } ?? []).filter { !$0.isEmpty }
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        // Local Persistence Keys (Used for saving to and loading from UserDefaults)
        case id, label, imageUrl, url, source, yield, calories, totalTime, mealType, dietLabels, healthLabels, ingredients, ingredientNames // 🔑 FIXED: Added ingredientNames here
        
        // API-Specific Keys (ONLY used for decoding from the external network API)
        case uri
        case image
        case ingredientLines
    }
    
    // MARK: - Convenience Initializer (Used by NetworkManager for Mapping)
    // This allows NetworkManager to build a MealModel from its internal API data structs.
    init(id: String, label: String, imageUrl: String, url: String, source: String, yield: Double, calories: Double, mealType: [String]?, dietLabels: [String]?, healthLabels: [String]?, ingredients: [String], ingredientNames: [String], totalTime: Double) { // 🔑 FIXED: Added ingredientNames parameter
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
        self.ingredientNames = ingredientNames // 🔑 FIXED: Assigned ingredientNames
        self.totalTime = totalTime
    }
    
    // MARK: - ENCODABLE CONFORMANCE (For Local Saving)
    // Manually implements saving using the Local Persistence Keys.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(url, forKey: .url)
        try container.encode(source, forKey: .source)
        try container.encode(yield, forKey: .yield)
        try container.encode(calories, forKey: .calories)
        try container.encode(totalTime, forKey: .totalTime)
        try container.encodeIfPresent(mealType, forKey: .mealType)
        try container.encodeIfPresent(dietLabels, forKey: .dietLabels)
        try container.encodeIfPresent(healthLabels, forKey: .healthLabels)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(ingredientNames, forKey: .ingredientNames) // 🔑 FIXED: Added ingredientNames to encode
    }
    
    // MARK: - DECÓDABLE CONFORMANCE (For Local Loading AND API Loading)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.image) {
            // Case 1: Decoding from the API (Spoonacular)
            
            self.label = try container.decode(String.self, forKey: .label)
            self.imageUrl = try container.decode(String.self, forKey: .image) // API key is "image"
            self.url = try container.decode(String.self, forKey: .url)
            self.source = try container.decode(String.self, forKey: .source)
            self.yield = try container.decode(Double.self, forKey: .yield)
            self.calories = try container.decode(Double.self, forKey: .calories)
            self.mealType = try container.decodeIfPresent([String].self, forKey: .mealType)
            self.dietLabels = try container.decodeIfPresent([String].self, forKey: .dietLabels)
            self.healthLabels = try container.decodeIfPresent([String].self, forKey: .healthLabels)
            self.ingredients = try container.decode([String].self, forKey: .ingredientLines) // API key is "ingredientLines"
            self.totalTime = try container.decode(Double.self, forKey: .totalTime)
            
            // API doesn't provide clean names directly in the summary, so we initialize to an empty array.
            // NetworkManager will call the convenience initializer later with the populated data.
            self.ingredientNames = []
            
            if let decodedId = try? container.decode(String.self, forKey: .id) {
                self.id = decodedId
            } else if let uri = try? container.decode(String.self, forKey: .uri), let idFragment = uri.split(separator: "_").last {
                self.id = String(idFragment)
            } else {
                self.id = UUID().uuidString
            }
            
        } else {
            // Case 2: Decoding from Local Storage (UserDefaults)
            
            self.id = try container.decode(String.self, forKey: .id)
            self.label = try container.decode(String.self, forKey: .label)
            self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
            self.url = try container.decode(String.self, forKey: .url)
            self.source = try container.decode(String.self, forKey: .source)
            self.yield = try container.decode(Double.self, forKey: .yield)
            self.calories = try container.decode(Double.self, forKey: .calories)
            self.mealType = try container.decodeIfPresent([String].self, forKey: .mealType)
            self.dietLabels = try container.decodeIfPresent([String].self, forKey: .dietLabels)
            self.healthLabels = try container.decodeIfPresent([String].self, forKey: .healthLabels)
            self.ingredients = try container.decode([String].self, forKey: .ingredients)
            self.totalTime = try container.decode(Double.self, forKey: .totalTime)
            self.ingredientNames = try container.decode([String].self, forKey: .ingredientNames) // 🔑 FIXED: Added ingredientNames to decode
        }
    }
}

// Struct to hold constraints for the API call
struct MealConstraints {
    let mealType: String
    let maxCalories: Int
    let healthConstraints: [String]
    
    init(mealType: String = "Dinner", maxCalories: Int = 1000, healthConstraints: [String] = []) {
            self.mealType = mealType
            self.maxCalories = maxCalories
            self.healthConstraints = healthConstraints
        }
    
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
