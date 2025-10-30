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


// MARK: NETWORK MANAGER (With robust decoding logic)

class NetworkManager: ObservableObject {
    @Published var isFetching = false
    
    // User's provided Edamam Credentials
    private let appId = "1192bcde"
    private let appKey = "0b487c1c405fc2c0e5d4852e1da64d08"
    private let baseURL = "https://api.edamam.com/api/recipes/v2"
    
    
    func fetchMeal(for constraints: MealConstraints, selectedDiet: String) async -> Result<MealModel, NetworkError> {
        // Set loading state
        await MainActor.run { isFetching = true }
        
        defer {
            // Ensure loading state is turned off when function exits
            Task { @MainActor in
                isFetching = false
            }
        }
        
        // 1. Construct the URL
        guard var components = URLComponents(string: baseURL) else {
            return .failure(.invalidURL)
        }
        
        // Determine the correct Edamam API mealType value based on the user's selection.
        let edamamMealType: String
        
        if constraints.mealType.lowercased().contains("breakfast") {
            edamamMealType = "breakfast"
        } else {
            edamamMealType = "lunch/dinner"
        }
        
        // 2. Build Query Items
        var queryItems = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "q", value: "recipe"), // Searches for general recipes
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            URLQueryItem(name: "mealType", value: edamamMealType),
            
            URLQueryItem(name: "calories", value: "0-\(constraints.maxCalories * 2)"),
            URLQueryItem(name: "diet", value: selectedDiet.lowercased()),
            URLQueryItem(name: "random", value: "true")
        ]
        
        // Add health constraints separately if they exist
        if !constraints.healthConstraints.isEmpty {
            for constraint in constraints.healthConstraints {
                queryItems.append(URLQueryItem(name: "health", value: constraint.lowercased().replacingOccurrences(of: " ", with: "-")))
            }
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            return .failure(.invalidURL)
        }
        
        print("\n*** API Request URL (Meal Planner) ***")
        print("Final URL: \(url.absoluteString)")
        
        // 3. Perform the Fetch
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                return .failure(.invalidResponse(statusCode))
            }
            
            // 4. Decode the Response
            let decodedResponse = try JSONDecoder().decode(EdamamResponse.self, from: data)
            
            guard let hit = decodedResponse.hits.first else {
                return .failure(.noResultsFound)
            }
            
            return .success(hit.recipe)
            
        } catch let decodingError as DecodingError {
            print("Decoding Error: \(decodingError)")
            return .failure(.decodingError(decodingError))
        } catch {
            print("Unknown Network Error: \(error.localizedDescription)")
            return .failure(.invalidResponse(nil))
        }
    }
    
    func fetchMealsForPlanner(count: Int, constraints: MealConstraints, selectedDiet: String) async -> Result<[MealModel], NetworkError> {
        await MainActor.run { isFetching = true }
        
        defer {
            Task { @MainActor in
                isFetching = false
            }
        }
        
        // 1. Construct the URL
        guard var components = URLComponents(string: baseURL) else {
            return .failure(.invalidURL)
        }
        
        let edamamMealType: String
        if constraints.mealType.lowercased().contains("breakfast") {
            edamamMealType = "breakfast"
        } else {
            edamamMealType = "lunch/dinner"
        }
        
        // 2. Build Query Items
        var queryItems = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "q", value: "recipe"),
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            URLQueryItem(name: "mealType", value: edamamMealType),
            
            // Use the 'to' parameter to specify the count of recipes to return
            URLQueryItem(name: "to", value: String(count)),
            
            URLQueryItem(name: "calories", value: "0-\(constraints.maxCalories * 2)"),
            URLQueryItem(name: "diet", value: selectedDiet.lowercased()),
            // REMOVED 'random=true' so we get the top results based on the query, up to 'to'
        ]
        
        if !constraints.healthConstraints.isEmpty {
            for constraint in constraints.healthConstraints {
                queryItems.append(URLQueryItem(name: "health", value: constraint.lowercased().replacingOccurrences(of: " ", with: "-")))
            }
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            return .failure(.invalidURL)
        }
        
        print("\n*** API Request URL (Weekly Planner - \(count) Meals) ***")
        print("Final URL: \(url.absoluteString)")
        
        // 3. Perform the Fetch
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                return .failure(.invalidResponse(statusCode))
            }
            
            // 4. Decode the Response
            let decodedResponse = try JSONDecoder().decode(EdamamResponse.self, from: data)
            
            // Return the array of all recipes found
            let meals = decodedResponse.hits.map { $0.recipe }
            
            if meals.isEmpty {
                return .failure(.noResultsFound)
            }
            
            return .success(meals)
            
        } catch let decodingError as DecodingError {
            print("Decoding Error: \(decodingError)")
            return .failure(.decodingError(decodingError))
        } catch {
            print("Unknown Network Error: \(error.localizedDescription)")
            return .failure(.invalidResponse(nil))
        }
    }
    
    
    /// Fetches a random meal from the Edamam API using the list of ingredients as the query.
    func fetchRecipeByInventory(ingredients: [String], maxCalories: Int, selectedDiet: String, healthConstraints: [String]) async -> Result<MealModel, NetworkError> {
        // Set loading state
        await MainActor.run { isFetching = true }
        
        defer {
            // Ensure loading state is turned off when function exits
            Task { @MainActor in
                isFetching = false
            }
        }
        
        // 1. Construct the URL
        guard var components = URLComponents(string: baseURL) else {
            return .failure(.invalidURL)
        }
        
        // Edamam uses the 'q' parameter for the search query, which can be a space-separated list.
        let ingredientQuery = ingredients.map { $0.lowercased() }.joined(separator: " ")
        
        // 2. Build Query Items (now including diet, calories, and random flag)
        var queryItems = [
            URLQueryItem(name: "type", value: "public"),
            // Use the list of ingredients as the main query
            URLQueryItem(name: "q", value: ingredientQuery),
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            
            // --- ADDED CONSTRAINTS HERE ---
            URLQueryItem(name: "calories", value: "0-\(maxCalories)"),
            URLQueryItem(name: "diet", value: selectedDiet.lowercased()),
            // -----------------------------
            
            // We want one random recipe based on the ingredients and constraints
            URLQueryItem(name: "random", value: "true"),
            // Optimize by requesting minimum fields
            URLQueryItem(name: "field", value: "label"),
            URLQueryItem(name: "field", value: "image"),
            URLQueryItem(name: "field", value: "url"),
            URLQueryItem(name: "field", value: "source"),
            URLQueryItem(name: "field", value: "ingredientLines"),
            URLQueryItem(name: "field", value: "calories"),
            URLQueryItem(name: "field", value: "totalTime"),
            URLQueryItem(name: "field", value: "yield"),
            URLQueryItem(name: "field", value: "uri"),
        ]
        
        // Add health constraints separately if they exist
        if !healthConstraints.isEmpty {
            for constraint in healthConstraints {
                // Edamam requires health constraints to be hyphenated and lowercase (e.g., "sugar-free")
                queryItems.append(URLQueryItem(name: "health", value: constraint.lowercased().replacingOccurrences(of: " ", with: "-")))
            }
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            return .failure(.invalidURL)
        }
        
        print("\n*** API Request URL (Inventory Finder) ***")
        print("Search Query: \(ingredientQuery)")
        print("Final URL: \(url.absoluteString)")
        
        // 3. Perform the Fetch
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                return .failure(.invalidResponse(statusCode))
            }
            
            // 4. Decode the Response
            let decodedResponse = try JSONDecoder().decode(EdamamResponse.self, from: data)
            
            guard let hit = decodedResponse.hits.first else {
                return .failure(.noResultsFound)
            }
            
            return .success(hit.recipe)
            
        } catch let decodingError as DecodingError {
            return .failure(.decodingError(decodingError))
        } catch {
            return .failure(.invalidResponse(nil))
        }
    }
}
