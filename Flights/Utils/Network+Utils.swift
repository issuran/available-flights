//
//  Network+Utils.swift
//  Flights
//
//  Created by Tiago Oliveira on 30/05/21.
//

import UIKit

final class NetworkUtils {
    class func decode<T: Decodable>(model: T.Type, data: Data?, response: URLResponse?, error: Error?, completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return completion(.failure(NSError(domain: "Invalid response", code: -999, userInfo: nil)))
        }
        
        guard 200 ... 299 ~= httpResponse.statusCode,
              data != nil else {
            return completion(.failure(NSError(domain: "Error", code: httpResponse.statusCode, userInfo: nil)))
        }
        
        guard let data = data,
              let result = try? JSONDecoder().decode(T.self, from: data) else {
            return completion(.failure(NSError(domain: "Could not decode payload", code: httpResponse.statusCode, userInfo: nil)))
        }
        
        return completion(.success(result))
    }
}
