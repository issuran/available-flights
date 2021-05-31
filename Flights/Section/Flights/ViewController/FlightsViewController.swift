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
        
    private lazy var viewModel = FlightsViewModel()
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
        viewModel.requestFlights(searchModel: searchModel)
    }
    
    @IBAction func dismissFlightsView(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        guard let model = searchModel else { return }
        titleLabel.text = "\(model.flightHeader())"
        viewModel.delegate = self
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
        if case let .content(trips) = sections[0] {
            return trips.first?.dates.count ?? 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[0] {
        case .loading, .empty, .error:
            return 1
        case .content(let trips):
            return trips.first?.dates[section].flights.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[0] {
        case .loading:
            return buildLoadingCell(indexPath)
        case .content(let trips):
            let trip = trips.first
            guard let flight = trips.first?.dates[indexPath.section].flights[indexPath.row] else { return UITableViewCell() }
            return buildFlightCell(indexPath, flight: flight, trip: trip)
        case .empty:
            return buildEmptyCell(indexPath)
        case .error:
            return buildErrorCell(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if case let .content(trips) = sections[0] {
            
            guard
                let date = trips.first?.dates[section].dateOut,
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FlightCellHeader") as? FlightCellHeader
            else { return UIView() }
            
            header.configure(viewModel.headerDateFormatter(date))
            
            return header
        }
        
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[0] {
        case .loading, .error, .empty:
            return 200.0
        case .content:
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
    
    private func buildFlightCell(_ indexPath: IndexPath, flight: FlightModel, trip: TripModel?) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FlightCell", for: indexPath) as? FlightCell else { return UITableViewCell() }
        
        cell.configure(flight: flight, trip: trip)
        
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
