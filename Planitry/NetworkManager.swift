//
//  NetworkManager.swift
//  Planitry
//
//  Created by Mamie Gartin on 10/12/25.
//

import Foundation
import Combine

// Top-level structure for Edamam API Response
struct EdamamResponse: Decodable {
    let hits: [RecipeHit]
}

// Intermediate structure for a single recipe hit
struct RecipeHit: Decodable {
    let recipe: MealModel
}
enum NetworkError: Error {
    case invalidURL
    case invalidResponse(Int?)
    case noResultsFound
    case decodingError(Error)
    case generalError(String)
}

// MARK: - Spoonacular Decoding Models

// New structure to handle the nutrition object returned when includeNutrition=true
struct SpoonacularNutrition: Decodable {
    let nutrients: [SpoonacularNutrient]
}

// New structure to specifically extract the calorie nutrient
struct SpoonacularNutrient: Decodable {
    let name: String
    let amount: Double
    let unit: String
}

struct SpoonacularSearchResponse: Decodable {
    let results: [SpoonacularSearchHit]
}

struct SpoonacularSearchHit: Decodable {
    let id: Int
    let title: String
    let image: String?
}

// Updated to include the nutrition data
struct SpoonacularRecipeDetails: Decodable {
    let title: String
    let sourceUrl: String
    let sourceName: String
    let image: String?
    let extendedIngredients: [SpoonacularIngredient]
    let servings: Int
    let readyInMinutes: Int?
    let nutrition: SpoonacularNutrition? // Now we can decode the nutrition data
}

struct SpoonacularIngredient: Decodable {
    let original: String
}

// MARK: - NETWORK MANAGER (Updated for Spoonacular/RapidAPI)

class NetworkManager: ObservableObject {
    @Published var isFetching = false
    
    // NOTE: Hardcoded keys can be expired or rate-limited, which might cause errors.
    // Replace with a valid key for testing.
    private let rapidApiKey = "5050af5467msh883cdbb98183321p15afd6jsn392b7873b3ab"
    
    private let rapidApiHost = "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
    private let baseURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/"
    
    private let session = URLSession.shared
    
    // MARK: - Core Fetch Function (Handles API Call and RapidAPI Headers)
    
    private func executeFetch<T: Decodable>(for url: URL, type: T.Type) async -> Result<T, NetworkError> {
        var request = URLRequest(url: url)
        
        // Set both RapidAPI headers
        request.setValue(rapidApiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue(rapidApiHost, forHTTPHeaderField: "X-RapidAPI-Host")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse(nil))
            }
            
            guard httpResponse.statusCode == 200 else {
                print("API Error Response: Status \(httpResponse.statusCode)")
                return .failure(.invalidResponse(httpResponse.statusCode))
            }
            
            let decodedResponse = try JSONDecoder().decode(type, from: data)
            return .success(decodedResponse)
            
        } catch let decodingError as DecodingError {
            print("Decoding Error: \(decodingError)")
            return .failure(.decodingError(decodingError))
        } catch {
            print("Unknown Network Error: \(error.localizedDescription)")
            return .failure(.invalidResponse(nil))
        }
    }
    
    // MARK: - Utility Function to Map Spoonacular Details to MealModel
    
    private func mapDetailsToMealModel(searchHit: SpoonacularSearchHit, details: SpoonacularRecipeDetails, constraints: MealConstraints, selectedDiet: String, healthConstraints: [String]) -> MealModel {
        
        let servings = Double(details.servings)
        let totalTime = Double(details.readyInMinutes ?? 0)
        let ingredients = details.extendedIngredients.map { $0.original }
        
        // --- Corrected Calories Extraction ---
        // 1. Find the "Calories" nutrient in the array
        let actualTotalCalories = details.nutrition?.nutrients.first { $0.name == "Calories" }?.amount ?? 0.0
        
        // We use the actual calorie count from the API instead of estimating
        
        return MealModel(
            id: String(searchHit.id),
            label: details.title,
            imageUrl: details.image ?? searchHit.image ?? "",
            url: details.sourceUrl,
            source: details.sourceName,
            yield: servings,
            calories: actualTotalCalories, // Use actual total calories for the recipe
            
            mealType: [constraints.mealType],
            dietLabels: selectedDiet.lowercased() == "balanced" ? nil : [selectedDiet],
            healthLabels: healthConstraints.isEmpty ? nil : healthConstraints,
            
            ingredients: ingredients,
            totalTime: totalTime,
            
            totalNutrients: [:]
        )
    }
    
    // MARK: - 1. Fetch Meal (Single Meal)
    
    func fetchMeal(for constraints: MealConstraints, selectedDiet: String) async -> Result<MealModel, NetworkError> {
        await MainActor.run { isFetching = true }
        let healthConstraints = constraints.healthConstraints.map { $0.lowercased() }
        defer { Task { @MainActor in isFetching = false } }
        
        // 1. Construct Search URL (Step 1) - complexSearch
        guard var searchComponents = URLComponents(string: baseURL + "complexSearch") else {
            return .failure(.invalidURL)
        }
        
        let spoonacularDiet = selectedDiet.lowercased() == "balanced" ? nil : selectedDiet.lowercased()
        let tagsQuery = healthConstraints.isEmpty ? "recipe" : healthConstraints.joined(separator: ", ")
        
        // Removed the * 2 multiplier from maxCalories to respect the user's input limit
        searchComponents.queryItems = [
            URLQueryItem(name: "query", value: tagsQuery),
            URLQueryItem(name: "type", value: constraints.mealType.lowercased()),
            URLQueryItem(name: "diet", value: spoonacularDiet),
            URLQueryItem(name: "maxCalories", value: String(constraints.maxCalories)), // Fixed multiplier
            URLQueryItem(name: "number", value: "1"),
            URLQueryItem(name: "sort", value: "random")
        ].compactMap { $0.value != nil ? $0 : nil }
        
        guard let searchURL = searchComponents.url else { return .failure(.invalidURL) }
        print("\n*** Spoonacular Single Search URL ***\n\(searchURL.absoluteString)")
        
        // 2. Perform Search (Get ID)
        let searchResult: Result<SpoonacularSearchResponse, NetworkError> = await executeFetch(for: searchURL, type: SpoonacularSearchResponse.self)
        
        guard case .success(let searchResponse) = searchResult, let hit = searchResponse.results.first else {
            return .failure(.noResultsFound)
        }
        
        // 3. Construct Details URL (Step 2) - information
        // *** FIX: Set includeNutrition=true to get actual calorie count ***
        guard let detailsURL = URL(string: baseURL + "\(hit.id)/information?includeNutrition=true") else {
            return .failure(.invalidURL)
        }
        
        // 4. Perform Details Fetch
        let detailsResult: Result<SpoonacularRecipeDetails, NetworkError> = await executeFetch(for: detailsURL, type: SpoonacularRecipeDetails.self)
        
        guard case .success(let details) = detailsResult else {
            return .failure(.generalError("Could not fetch recipe details for ID: \(hit.id)"))
        }
        
        // 5. Map and Return
        let meal = mapDetailsToMealModel(searchHit: hit, details: details, constraints: constraints, selectedDiet: selectedDiet, healthConstraints: healthConstraints)
        return .success(meal)
    }
    
    // MARK: - 2. Fetch Meals for Planner (Multiple Meals)
    
    func fetchMealsForPlanner(count: Int, constraints: MealConstraints, selectedDiet: String) async -> Result<[MealModel], NetworkError> {
        await MainActor.run { isFetching = true }
        let healthConstraints = constraints.healthConstraints.map { $0.lowercased() }
        defer { Task { @MainActor in isFetching = false } }
        
        // 1. Construct Search URL (Step 1) - complexSearch
        guard var searchComponents = URLComponents(string: baseURL + "complexSearch") else {
            return .failure(.invalidURL)
        }
        
        let spoonacularDiet = selectedDiet.lowercased() == "balanced" ? nil : selectedDiet.lowercased()
        let tagsQuery = healthConstraints.isEmpty ? "recipe" : healthConstraints.joined(separator: ", ")
        
        searchComponents.queryItems = [
            URLQueryItem(name: "query", value: tagsQuery),
            URLQueryItem(name: "type", value: constraints.mealType.lowercased()),
            URLQueryItem(name: "diet", value: spoonacularDiet),
            URLQueryItem(name: "maxCalories", value: String(constraints.maxCalories)), // Fixed multiplier
            URLQueryItem(name: "number", value: String(count)),
            URLQueryItem(name: "sort", value: "random")
        ].compactMap { $0.value != nil ? $0 : nil }
        
        guard let searchURL = searchComponents.url else { return .failure(.invalidURL) }
        print("\n*** Spoonacular Planner Search URL (Count: \(count)) ***\n\(searchURL.absoluteString)")
        
        // 2. Perform Search (Get IDs)
        let searchResult: Result<SpoonacularSearchResponse, NetworkError> = await executeFetch(for: searchURL, type: SpoonacularSearchResponse.self)
        
        guard case .success(let searchResponse) = searchResult, !searchResponse.results.isEmpty else {
            return .failure(.noResultsFound)
        }
        
        // 3. Batch Fetch Details (Step 2)
        var meals: [MealModel] = []
        
        for hit in searchResponse.results {
            // *** FIX: Set includeNutrition=true to get actual calorie count ***
            guard let detailsURL = URL(string: baseURL + "\(hit.id)/information?includeNutrition=true") else { continue }
            
            let detailsResult: Result<SpoonacularRecipeDetails, NetworkError> = await executeFetch(for: detailsURL, type: SpoonacularRecipeDetails.self)
            
            if case .success(let details) = detailsResult {
                let meal = mapDetailsToMealModel(searchHit: hit, details: details, constraints: constraints, selectedDiet: selectedDiet, healthConstraints: healthConstraints)
                meals.append(meal)
            }
        }
        
        return meals.isEmpty ? .failure(.noResultsFound) : .success(meals)
    }
    
    // MARK: - 3. Fetch Recipe by Inventory
    
    func fetchRecipeByInventory(ingredients: [String], maxCalories: Int, selectedDiet: String, healthConstraints: [String]) async -> Result<MealModel, NetworkError> {
        await MainActor.run { isFetching = true }
        let currentConstraints = MealConstraints(mealType: "Any", maxCalories: maxCalories, healthConstraints: healthConstraints)
        let processedHealthConstraints = healthConstraints.map { $0.lowercased() }
        defer { Task { @MainActor in isFetching = false } }
        
        // 1. Construct Search URL (Step 1) - findByIngredients
        guard var searchComponents = URLComponents(string: baseURL + "findByIngredients") else {
            return .failure(.invalidURL)
        }
        
        let ingredientList = ingredients.map { $0.lowercased() }.joined(separator: ",")
        
        searchComponents.queryItems = [
            URLQueryItem(name: "ingredients", value: ingredientList),
            URLQueryItem(name: "number", value: "1"),
            URLQueryItem(name: "ranking", value: "1"), // Minimize missing ingredients
        ]
        
        guard let searchURL = searchComponents.url else { return .failure(.invalidURL) }
        print("\n*** Spoonacular Inventory Search URL ***\n\(searchURL.absoluteString)")
        
        // 2. Perform Search (Get ID)
        let searchResult: Result<[SpoonacularSearchHit], NetworkError> = await executeFetch(for: searchURL, type: [SpoonacularSearchHit].self)
        
        guard case .success(let hits) = searchResult, let hit = hits.first else {
            return .failure(.noResultsFound)
        }
        
        // 3. Construct Details URL (Step 2) - information
        // *** FIX: Set includeNutrition=true to get actual calorie count ***
        guard let detailsURL = URL(string: baseURL + "\(hit.id)/information?includeNutrition=true") else {
            return .failure(.invalidURL)
        }
        
        // 4. Perform Details Fetch
        let detailsResult: Result<SpoonacularRecipeDetails, NetworkError> = await executeFetch(for: detailsURL, type: SpoonacularRecipeDetails.self)
        
        guard case .success(let details) = detailsResult else {
            return .failure(.generalError("Could not fetch recipe details for ID: \(hit.id)"))
        }
        
        // 5. Map and Return
        let meal = mapDetailsToMealModel(searchHit: hit, details: details, constraints: currentConstraints, selectedDiet: selectedDiet, healthConstraints: processedHealthConstraints)
        return .success(meal)
    }
}
