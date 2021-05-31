//
//  SearchViewModel.swift
//  Flights
//
//  Created by Tiago Oliveira on 25/05/21.
//

import Foundation

class SearchViewModel {
    
    // MARK: - Variables
    
    let adultsPassenger = [1, 2, 3, 4, 5, 6]
    let teenPassenger = [0, 1, 2, 3, 4, 5, 6]
    let childrenPassenger = [0, 1, 2, 3, 4, 5, 6]
    
    var airports: AirportsModel?
    
    // MARK: - Public Methods
    
    public func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    public func requestAirports(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://tripstest.ryanair.com/static/stations.json") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("ios", forHTTPHeaderField: "client")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            NetworkUtils.decode(model: AirportsModel.self, data: data, response: response, error: error) { (result) in
                switch result {
                case .success(let data):
                    self.airports = data
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
