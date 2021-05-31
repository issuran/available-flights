//
//  FlightCell.swift
//  Flights
//
//  Created by Tiago Oliveira on 27/05/21.
//

import UIKit

class FlightCell: UITableViewCell {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var stationDepartureLabel: UILabel!
    @IBOutlet private weak var timeDepartureLabel: UILabel!
    @IBOutlet private weak var timeArriveLabel: UILabel!
    @IBOutlet private weak var stationArriveLabel: UILabel!
    @IBOutlet private weak var flightNumberLabel: UILabel!
    @IBOutlet private weak var fareLabel: UILabel!
    
    // MARK: Lifecycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clearContent()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        clearContent()
    }
    
    // MARK: - Private Methods
        
    private func clearContent() {
        timeDepartureLabel.text = ""
        timeArriveLabel.text = ""
        flightNumberLabel.text = ""
        fareLabel.text = ""
    }
    
    private func dateFormatter(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func calculeFare(_ fare: [Fare]?) -> String {
        guard let fare = fare else { return "-" }
        var total = 0.0
        
        fare.forEach { (fare) in
            total += Double(fare.count) * fare.amount
        }
        
        return String(format: "€%.02f", total)
    }
    
    // MARK: - Public Methods
    
    public func configure(flight: FlightModel, trip: TripModel?) {
        var timeDeparture: Date? = nil
        var timeArrive: Date? = nil
        
        if flight.time.count > 1 {
            timeDeparture = flight.time[0]
            timeArrive = flight.time[1]
        }
        
        flightNumberLabel.text = flight.flightNumber
        
        stationDepartureLabel.text = trip?.originName
        timeDepartureLabel.text = dateFormatter(timeDeparture)
        
        timeArriveLabel.text = dateFormatter(timeArrive)
        stationArriveLabel.text = trip?.destinationName
        
        fareLabel.text = calculeFare(flight.regularFare?.fares)
    }
    
    // MARK: - Memory Managements
    
    deinit {
        debugPrint("Deinit AirportCell")
    }
    
}
