//
//  CurrentWeatherViewModel.swift
//  WeatherApp
//
//  Created by Bhoopendra Umrao on 02/04/23.
//

import Foundation

protocol CurrentWeatherViewModel: ObservableObject {
    var currentWeather: CurrentWeather? { get }
    var forecastWeatherList: [WeatherForecast] { get }
    var showError: Bool { get set }
    var currentErrorMessage: String? { get }
    func didFetch()
}

final class DefaultCurrentWeatherViewModel: CurrentWeatherViewModel {

    @Published var currentWeather: CurrentWeather?
    @Published var forecastWeatherList: [WeatherForecast] = []
    @Published var showError: Bool = false

    private var weatherUseCase: WeatherUseCase
    private let locationQuery: String

    var currentErrorMessage: String?

    /// Initialise with any type conforming to WeatherUseCase protocol
    /// - Parameters:
    ///   - weatherUseCase: WeatherUseCase
    ///   - locationQuery: Location string for weather lookup (default: Edmonton, AB, Canada)
    init(weatherUseCase: WeatherUseCase, locationQuery: String = "Edmonton, AB, Canada") {
        self.weatherUseCase = weatherUseCase
        self.locationQuery = locationQuery
    }

    /// Fetch current weather and forecast
    func didFetch() {
        Task {
            do {
                let weather = try await weatherUseCase.fetchCurrentWeather(query: locationQuery)
                await MainActor.run { [weather] in
                    currentWeather = weather
                }

                guard let weather = weather else { return }
                let forecast = try await weatherUseCase.fetchWeatherForeCast(
                    lat: "\(weather.location?.lat ?? 0.0)",
                    long: "\(weather.location?.long ?? 0.0)"
                )
                await MainActor.run { [forecast] in
                    forecastWeatherList = forecast ?? []
                }
            } catch {
                await MainActor.run { [error] in
                    currentErrorMessage = error.localizedDescription
                    showError.toggle()
                }
            }
        }
    }
}
