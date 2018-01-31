//
//  API.swift
//  NiceWeather
//
//  Created by Riyazh Dholakia on 12/7/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation

public var api_key: String?

public func requestForecast(for location: CLLocation, completion: @escaping (Forecast?, Error?) -> Void) {
    request(forecast_request_url(coordinate: location.coordinate), queryItems: defaultQueryItems) { (result) in
        switch result {
        case .failure(let error):
            completion(nil, error)
        case .success(let data):
            do {
                let forecast = try decoder.decode(Forecast.self, from: data)
                completion(forecast, nil)
            }
            catch { completion(nil, APIError.unexpectedResult(data, error)) }
        }
    }
}

private var defaultQueryItems = ["exclude": "minutely,flags"]

private var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return decoder
}

private func forecast_request_url(coordinate: CLLocationCoordinate2D) -> String {
    guard let key = api_key else { fatalError(APIError.secretKeyNotSet.description) }
    return "https://api.darksky.net/forecast/\(key)/\(coordinate.latitude),\(coordinate.longitude)"
}


enum APIError: Error, CustomStringConvertible {
    case secretKeyNotSet
    case unexpectedResult(Data, Error)
    
    var description: String {
        switch self {
        case .secretKeyNotSet:
            return "DarkSky Error: A secret key has not been set. You must set a secret key before making requests. Create an account at https://darksky.net/dev/ then set `DarkSky.api_key` with your secret key."
        case .unexpectedResult(let data, let error):
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return "DarkSky Error: The request returned data in an unexpected format. The requested location may have incomplete data, or an unhandled error may have occurred. Inspecting the data may reveal the cause:\n\(error)\n\(String(describing: json))"
        }
    }
}

