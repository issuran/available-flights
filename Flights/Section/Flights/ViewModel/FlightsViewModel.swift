//
//  FlightsViewModel.swift
//  Flights
//
//  Created by Tiago Oliveira on 27/05/21.
//

import Foundation

protocol FlightsViewModelProvider {
    var flights: FlightsModel? { get }
    var sections: [FlightsStateSection] { get }
    
    func dateFormatter(_ date: Date) -> String
    func headerDateFormatter(_ date: Date) -> String
    func requestFlights(searchModel: FlightsSearchModel?)
    func processResult(_ result: Result<FlightsModel, Error>)
    func processSuccess(flights: [TripModel])
    func processFailure(error: Error)
}

enum FlightsStateSection {
    case loading
    case data(DateTripModel, String, String)
    case empty
    case error
}

class FlightsViewModel: FlightsViewModelProvider {
    
    // MARK: - Variables
    
    var flights: FlightsModel?
    var sections: [FlightsStateSection] = [.loading]
    weak var delegate: FlightsViewModelViewDelegate?
    
    // MARK: - Public Methods
    
    init(_ delegate: FlightsViewController) {
        self.delegate = delegate
    }
    
    func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func headerDateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    func requestFlights(searchModel: FlightsSearchModel?) {
        guard
            let origin = searchModel?.origin,
            let destination = searchModel?.destination,
            let date = searchModel?.date,
            let adults = searchModel?.adults,
            let teen = searchModel?.teen,
            let children = searchModel?.children
        else { return }

        let dateout = dateFormatter(date)

        guard let url = URL(string: "https://sit-nativeapps.ryanair.com/api/v4/Availability?origin=\(origin)&destination=\(destination)&dateout=\(dateout)&datein=&flexdaysbeforeout=3&flexdaysout=3&flexdaysbeforein=3&flexdaysin=3&adt=\(adults)&teen=\(teen)&chd=\(children)&roundtrip=false&ToUs=AGREED") else { return }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("ios", forHTTPHeaderField: "client")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            NetworkUtils.decode(model: FlightsModel.self, data: data, response: response, error: error) { (result) in
                self.processResult(result)
            }
        }

        task.resume()
    }
    
    func processResult(_ result: Result<FlightsModel, Error>) {
        switch result {
        case .success(let data):
            self.flights = data
            self.sections = []
            processSuccess(flights: data.trips)

        case .failure(let error):
            processFailure(error: error)
        }
    }
    
    func processSuccess(flights: [TripModel]) {
        guard flights.count > 0 else {
            DispatchQueue.main.async {
                self.sections = [.empty]
                self.delegate?.updateState(self, sections: self.sections)
                return
            }
            return
        }
        
        guard let dates = flights.first?.dates else {
            self.sections = [.empty]
            self.delegate?.updateState(self, sections: self.sections)
            return
        }
        
        self.sections = []
            
        dates.forEach { (dateTrip) in
            if dateTrip.flights.count > 0 {
                self.sections.append(.data(dateTrip, flights.first?.originName ?? "", flights.first?.destinationName ?? ""))
            }
        }
        
        guard sections.count > 0 else {
            DispatchQueue.main.async {
                self.sections = [.empty]
                self.delegate?.updateState(self, sections: self.sections)
                return
            }
            return
        }
        
        self.delegate?.updateState(self, sections: self.sections)
    }
    
    func processFailure(error: Error) {
        self.sections = [.error]
        self.delegate?.updateState(self, sections: self.sections)
        return
    }
}
