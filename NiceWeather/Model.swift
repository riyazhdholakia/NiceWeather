//
//  Model.swift
//  NiceWeather
//
//  Created by Riyazh Dholakia on 12/7/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation

/// A representation of the current and upcoming weather conditions for a particular area.
public struct Forecast: Decodable {
    
    /// The requested latitude.
    public let latitude: Double
    
    /// The requested longitude.
    public let longitude: Double
    
    /// The timezone name for the requested location e.g. `America/Los_Angeles`.
    public let timezone: String
    
    /// The current weather conditions at the requested location
    public let currently: MomentaryCondition
    
    /// A human-readable summary of the next two days' conditions.
    public let hourlySummary: String?
    
    /// The weather conditions hour-by-hour for the next two days.
    public let hourly: [MomentaryCondition]
    
    /// A human-readable summary of the next week's conditions.
    public let dailySummary: String?
    
    /// The weather conditions day-by-day for the next week.
    public let daily: [AverageCondition]
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, timezone, currently, hourly, daily
    }
    
    enum ForecastSliceKeys: String, CodingKey {
        case summary, icon, data
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
        timezone = try values.decode(String.self, forKey: .timezone)
        currently = try values.decode(MomentaryCondition.self, forKey: .currently)
        
        let hourlySlice = try values.nestedContainer(keyedBy: ForecastSliceKeys.self, forKey: .hourly)
        hourlySummary = try hourlySlice.decode(String.self, forKey: .summary)
        hourly = try hourlySlice.decode([MomentaryCondition].self, forKey: .data)
        
        let dailySlice = try values.nestedContainer(keyedBy: ForecastSliceKeys.self, forKey: .daily)
        dailySummary = try dailySlice.decode(String.self, forKey: .summary)
        daily = try dailySlice.decode([AverageCondition].self, forKey: .data)
    }
}

import UIKit.UIImage

extension UIImage {
    convenience init?(_ name: String) {
        self.init(named: name, in: Bundle(for: WeatherCondition.self), compatibleWith: nil)
    }
}

/// An abstract base class for weather condition representations within a particular period of time.
/// - Note: This class is not itself wholly representative of any data point from DarkSky's API.
/// The concrete subclasses `AverageCondition` and `MomentaryCondition` should be used instead.
public class WeatherCondition: Decodable {
    
    /// The date and time at which this condition begins.
    /// Hourly conditions are the top of the hour, and daily conditions are midnight of the day, both according to the local time zone.
    public let time: Date
    
    /// A human-readable text summary of the condition.
    public let summary: String?
    
    /// A machine-readable summary of the condition, suitable for selecting an icon for display.
    public let icon: Icon
    
    /// The probability of precipitation occurring, between 0 and 1, inclusive.
    public let precipProbability: Double
    
    /// The type of precipitation occurring.
    public let precipType: PrecipitationType
    
    /// The relative humidity, between 0 and 1.
    public let humidity: Double
    
    /// The wind speed in miles per hour.
    public let windSpeed: Double
    
    /// The wind gust speed in miles per hour.
    public let windGust: Double
    
    /// The direction that the wind is coming from in degrees, with true north at 0° and progressing clockwise.
    /// - Note: If `windSpeed` is 0 this property will be nil.
    public let windBearing: Int?
    
    /// The average visibility in miles, capped at 10 miles.
    public let visibility: Double
    
    /// The percentage of sky occluded by clouds, between 0 and 1.
    public let cloudCover: Double
    
    public enum PrecipitationType: String {
        case rain, snow, sleet, none
        
        public typealias RawValue = String
        
        init(rawValue: String?) {
            guard let rawValue = rawValue else { self = .none; return }
            
            switch rawValue {
            case PrecipitationType.rain.rawValue: self = .rain
            case PrecipitationType.snow.rawValue: self = .snow
            case PrecipitationType.sleet.rawValue: self = .sleet
            default: self = .none
            }
        }
    }
    
    public enum Icon: String {
        case rain, snow, sleet, wind, fog, cloudy, none
        case clearDay = "clear-day"
        case clearNight = "clear-night"
        case partlyCloudyDay = "partly-cloudy-day"
        case partlyCloudyNight = "partly-cloudy-night"
        
        public typealias RawValue = String
        
        init(rawValue: String?) {
            guard let rawValue = rawValue else { self = .none; return }
            
            switch rawValue {
            case Icon.rain.rawValue: self = .rain
            case Icon.snow.rawValue: self = .snow
            case Icon.sleet.rawValue: self = .sleet
            case Icon.wind.rawValue: self = .wind
            case Icon.fog.rawValue: self = .fog
            case Icon.cloudy.rawValue: self = .cloudy
            case Icon.clearDay.rawValue: self = .clearDay
            case Icon.clearNight.rawValue: self = .clearNight
            case Icon.partlyCloudyDay.rawValue: self = .partlyCloudyDay
            case Icon.partlyCloudyNight.rawValue: self = .partlyCloudyNight
            default: self = .none
            }
        }
        
        public var image: UIImage {
            switch self {
            case .rain: return UIImage(rawValue)!
            case .snow, .sleet: return UIImage(Icon.snow.rawValue)!
            case .wind: return UIImage(rawValue)!
            case .fog, .cloudy: return UIImage(Icon.cloudy.rawValue)!
            case .clearDay: return UIImage(rawValue)!
            case .clearNight: return UIImage(rawValue)!
            case .partlyCloudyDay, .partlyCloudyNight: return UIImage(Icon.partlyCloudyDay.rawValue)!
            case .none: return UIImage()
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case time, summary, icon, precipProbability, precipType, humidity, windSpeed, windGust, windBearing, visibility, cloudCover
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        time = try values.decode(Date.self, forKey: .time)
        summary = try? values.decode(String.self, forKey: .summary)
        icon = Icon.init(rawValue: try? values.decode(String.self, forKey: .icon))
        precipProbability = try values.decode(Double.self, forKey: .precipProbability)
        precipType = PrecipitationType.init(rawValue: try? values.decode(String.self, forKey: .precipType))
        humidity = try values.decode(Double.self, forKey: .humidity)
        windSpeed = (try? values.decode(Double.self, forKey: .windSpeed)) ?? 0
        windGust = (try? values.decode(Double.self, forKey: .windGust)) ?? 0
        windBearing = try? values.decode(Int.self, forKey: .windBearing)
        visibility = (try? values.decode(Double.self, forKey: .visibility)) ?? 10
        cloudCover = (try? values.decode(Double.self, forKey: .cloudCover)) ?? 0
    }
    
}

/// The average weather conditions over an extended period of time e.g. a day.
public final class AverageCondition: WeatherCondition {
    
    /// The maximum value of `temperature` during a given day.
    public let temperatureMax: Double
    
    /// The minimum value of `temperature` during a given day.
    public let temperatureMin: Double
    
    private enum AverageCodingKeys: CodingKey {
        case temperatureMax, temperatureMin
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AverageCodingKeys.self)
        temperatureMax = try values.decode(Double.self, forKey: .temperatureMax)
        temperatureMin = try values.decode(Double.self, forKey: .temperatureMin)
        try super.init(from: decoder)
    }
    
}

/// The weather conditions for a particular moment in time e.g. the present.
public final class MomentaryCondition: WeatherCondition {
    
    /// The air temperature in degrees Fahrenheit.
    public let temperature: Double
    
    /// The apparent (or “feels like”) temperature in degrees Fahrenheit.
    public let apparentTemperature: Double
    
    private enum MomentaryCodingKeys: CodingKey {
        case temperature, apparentTemperature
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: MomentaryCodingKeys.self)
        let actualTemp = try values.decode(Double.self, forKey: .temperature)
        
        apparentTemperature = (try? values.decode(Double.self, forKey: .apparentTemperature)) ?? actualTemp
        temperature = actualTemp
        
        try super.init(from: decoder)
    }
}

