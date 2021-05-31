//
//  AirportsModel.swift
//  Flights
//
//  Created by Tiago Oliveira on 26/05/21.
//

import UIKit

struct AirportsModel: Codable {
    let stations: [AirportModel]
}

struct AirportModel: Codable {
    let code: String?
    let countryName: String?
    let name: String?
}
