//
//  WeatherError.swift
//  WeatherApp
//
//  Created by Sakir Saiyed.
//

import Foundation

/// Domain-level errors for weather operations.
enum WeatherError: LocalizedError {
    case networkFailure(underlying: Error)
    case decodingFailure(underlying: Error)
    case locationNotFound(query: String)
    case invalidAPIKey

    var errorDescription: String? {
        switch self {
        case .networkFailure(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingFailure(let error):
            return "Failed to parse weather data: \(error.localizedDescription)"
        case .locationNotFound(let query):
            return "Location not found: \(query)"
        case .invalidAPIKey:
            return "Invalid or missing API key"
        }
    }
}
