//
//  SelectAirportViewModel.swift
//  Flights
//
//  Created by Tiago Oliveira on 31/05/21.
//

import Foundation

protocol SelectAirportViewModelProvider {
    var orderedAirports: [AirportModel] { get set }
    var filteredAirports: [AirportModel] { get set }
    var origin: OriginAirport { get set }
    var searchSection: [SearchStateSection] { get set }
    
    func filterAirports(_ text: String)
    func resetAirportsFiltered()
    func section(_ section: Int) -> SearchStateSection
    func selectedStation() -> OriginAirport
}

class SelectAirportViewModel: SelectAirportViewModelProvider {
    var orderedAirports: [AirportModel]
    var filteredAirports: [AirportModel]
    var origin: OriginAirport
    var searchSection: [SearchStateSection]
    
    init(_ airports: AirportsModel, origin: OriginAirport) {
        self.orderedAirports = airports.stations.sorted { ($0.countryName ?? "", $0.name ?? "") < ($1.countryName ?? "", $1.name ?? "") }
        self.origin = origin
        self.filteredAirports = orderedAirports
        self.searchSection = [.content(filteredAirports)]
    }
    
    func filterAirports(_ text: String) {
        filteredAirports = orderedAirports.filter({ (airport) -> Bool in
            let filterText = text.lowercased().folding(options: .diacriticInsensitive, locale: nil)
            let concatenedWord = "\(airport.code ?? "") \(airport.countryName ?? "") \(airport.name ?? "")"
            return concatenedWord
                .folding(options: .diacriticInsensitive, locale: nil)
                .lowercased()
                .contains(filterText)
        })
        
        if filteredAirports.count > 0 {
            searchSection = [.content(filteredAirports)]
        } else {
            searchSection = [.empty]
        }
    }
    
    func resetAirportsFiltered() {
        filteredAirports = orderedAirports
        searchSection = [.content(filteredAirports)]
    }
    
    func section(_ section: Int) -> SearchStateSection {
        return searchSection[section]
    }
    
    func selectedStation() -> OriginAirport {
        return origin
    }
}
