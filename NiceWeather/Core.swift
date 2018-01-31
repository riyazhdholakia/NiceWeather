//
//  Core.swift
//  NiceWeather
//
//  Created by Riyazh Dholakia on 12/7/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation

enum HTTPError: Error {
    case unexpectedResult
    case unknown(HTTPURLResponse?)
    case malformedRequest
}

enum Result {
    case success(Data)
    case failure(Error)
}

/**
 Asynchronously performs an HTTP GET request with the provided URL, appending any optional query items to the URL, then calls the completion handler on the main thread with the `Result` of the request containing the received data if successful or the error upon failure.
 
 - Note: A response is not considered a success unless its status code is within the 200 range.
 
 - Parameters:
 - urlString: The string representation of the URL with which to make the request
 - queryItems: The dictionary of query items to append to the request, if desired
 - completion: The function to be called with the `Result` when the request completes
 */
func request(_ urlString: String, queryItems: [String:String] = [String:String](), completion: @escaping (Result) -> Void) {
    guard let url: URL = {
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = queryItems.map { URLQueryItem(name: $0, value: $1) }
        return urlComponents?.url
        }() else { return completion(.failure(HTTPError.malformedRequest)) }
    
    URLSession.shared.dataTask(with: url) { (data, resp, error) in
        if let httpResp = resp as? HTTPURLResponse, !(200...299).contains(httpResp.statusCode) {
            DispatchQueue.main.async { completion(.failure(HTTPError.unknown(httpResp))) }
        } else if let error = error {
            DispatchQueue.main.async { completion(.failure(error)) }
        } else if let data = data {
            DispatchQueue.main.async { completion(.success(data)) }
        } else {
            DispatchQueue.main.async { completion(.failure(HTTPError.unknown(resp as? HTTPURLResponse))) }
        }
        }.resume()
}

