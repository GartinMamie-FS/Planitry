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
    

    private let appId = "1192bcde"
    private let appKey = "0b487c1c405fc2c0e5d4852e1da64d08"

    /// Fetches a random meal from the Edamam API based on user constraints.
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
        guard var components = URLComponents(string: "https://api.edamam.com/api/recipes/v2") else {
            return .failure(.invalidURL)
        }
        
        // Removed the unnecessary 'healthQuery' variable here as it's not used.
        
        // 2. Build Query Items
        var queryItems = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "q", value: "recipe"),
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            URLQueryItem(name: "mealType", value: constraints.mealType.lowercased()),
            URLQueryItem(name: "calories", value: "0-\(constraints.maxCalories * 2)"),
            URLQueryItem(name: "diet", value: selectedDiet.lowercased()),
            URLQueryItem(name: "random", value: "true")
        ]
        
        // Add health constraints separately if they exist
        if !constraints.healthConstraints.isEmpty {
            for constraint in constraints.healthConstraints {
                // Ensure the constraint is formatted correctly (e.g., "gluten-free")
                queryItems.append(URLQueryItem(name: "health", value: constraint.lowercased().replacingOccurrences(of: " ", with: "-")))
            }
        }

        components.queryItems = queryItems
        
        guard let url = components.url else {
            return .failure(.invalidURL)
        }
        
        print("\n*** API Request URL ***")
        print("Final URL: \(url.absoluteString)")
        print("Final Diet Parameter: \(selectedDiet)")
        print("Final Health Constraints: \(constraints.healthConstraints.joined(separator: ", "))")
        print("Total Recipe Calorie Limit: 0-\(constraints.maxCalories * 2)")
        
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
}
