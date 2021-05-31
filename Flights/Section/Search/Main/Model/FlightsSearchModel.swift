//
//  FlightsSearchModel.swift
//  Flights
//
//  Created by Tiago Oliveira on 25/05/21.
//

import Foundation

class FlightsSearchModel {
    var adults: Int = 1
    var teen: Int = 0
    var children: Int = 0
    var date: Date?
    var origin: String?
    var destination: String?
    
    // MARK: - Methods
    
    func isValid() -> Bool {
        guard date != nil,
              origin != nil,
              destination != nil
        else { return false }
        return true
    }
    
    func flightHeader() -> String {
        guard let origin = origin,
              let destination = destination
        else { return "=(" }
        
        return "\(origin) > \(destination)"
    }
}
