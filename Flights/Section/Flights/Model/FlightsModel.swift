//
//  FlightsModel.swift
//  Flights
//
//  Created by Tiago Oliveira on 27/05/21.
//

import UIKit

struct FlightsModel: Codable {
    let trips: [TripModel]
}

struct TripModel: Codable {
    let origin: String
    let originName: String
    let destination: String
    let destinationName: String
    let dates: [DateTripModel]
}

struct DateTripModel: Codable {
    let dateOut: String
    let flights: [FlightModel]
    
    public var dateoutDate: Date? {
        get {
            return DateFormatter.iso3339.date(from: dateOut)
        }
    }
}

struct FlightModel: Codable {
    let time: [String]
    let regularFare: RegularFare?
    let flightNumber: String
}

struct RegularFare: Codable {
    let fares: [Fare]
}

struct Fare: Codable {
    let amount: Double
    let count: Int
}
