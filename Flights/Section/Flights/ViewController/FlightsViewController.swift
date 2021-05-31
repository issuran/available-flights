//
//  FlightsViewController.swift
//  Flights
//
//  Created by Tiago Oliveira on 27/05/21.
//

import UIKit

protocol FlightsViewModelViewDelegate: AnyObject {
    func updateState(_ viewModel: FlightsViewModel, sections: [FlightsStateSection])
}

final class FlightsViewController: BaseViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Variables
        
    private var viewModel: FlightsViewModelProvider?
    private var searchModel: FlightsSearchModel?
    private var sections: [FlightsStateSection] = [.loading]
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureTableView()
        requestFlights()
    }
    
    // MARK: - Network Methods
    
    private func requestFlights() {
        viewModel?.requestFlights(searchModel: searchModel)
    }
    
    @IBAction func dismissFlightsView(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        guard let model = searchModel else { return }
        viewModel = FlightsViewModel(self)
        titleLabel.text = "\(model.flightHeader())"
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "LoadingCell", bundle: nil), forCellReuseIdentifier: "LoadingCell")
        tableView.register(UINib(nibName: "FlightCell", bundle: nil), forCellReuseIdentifier: "FlightCell")
        tableView.register(UINib(nibName: "EmptyCell", bundle: nil), forCellReuseIdentifier: "EmptyCell")
        tableView.register(UINib(nibName: "ErrorCell", bundle: nil), forCellReuseIdentifier: "ErrorCell")

        tableView.register(UINib(nibName: "FlightCellHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "FlightCellHeader")
        
        tableView.reloadData()
    }
    
    // MARK: - Public Methods
    
    public func configure(_ model: FlightsSearchModel) {
        self.searchModel = model
    }
    
    // MARK: - Deinit Method
    
    deinit {
        debugPrint("Deinit FlightsViewController")
    }
    
}

extension FlightsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .loading, .empty, .error:
            return 1
        case .data(let trip, _, _):
            return trip.flights.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .loading:
            return buildLoadingCell(indexPath)
        case .empty:
            return buildEmptyCell(indexPath)
        case .error:
            return buildErrorCell(indexPath)
        case .data(let trip, let originName, let destinationName):
            let flight = trip.flights[indexPath.row]
            return buildFlightCell(indexPath, flight: flight, origin: originName, destination: destinationName)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel = viewModel else { return nil}
        if case let .data(trip, _, _) = sections[section] {
            
            guard
                let date = trip.dateoutDate,
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FlightCellHeader") as? FlightCellHeader
            else { return UIView() }
            
            header.configure(viewModel.headerDateFormatter(date))
            
            return header
        }
        
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .loading, .error, .empty:
            return 200.0
        case .data:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
}

extension FlightsViewController {
    private func buildLoadingCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as? LoadingCell else { return UITableViewCell() }
        
        cell.configure()
        
        return cell
    }
    
    private func buildFlightCell(_ indexPath: IndexPath, flight: FlightModel, origin: String, destination: String) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FlightCell", for: indexPath) as? FlightCell else { return UITableViewCell() }
        
        cell.configure(flight: flight, origin: origin, destination: destination)
        
        return cell
    }
    
    private func buildEmptyCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath)
        
        return cell
    }
    
    private func buildErrorCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell", for: indexPath)
        
        return cell
    }
}

extension FlightsViewController: FlightsViewModelViewDelegate {
    func updateState(_ viewModel: FlightsViewModel, sections: [FlightsStateSection]) {
        DispatchQueue.main.async {
            self.sections = sections
            self.tableView.reloadData()
        }
    }
}
