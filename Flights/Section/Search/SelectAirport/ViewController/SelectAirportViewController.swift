//
//  SelectAirportViewController.swift
//  Flights
//
//  Created by Tiago Oliveira on 26/05/21.
//

import UIKit

protocol SelectAirportDelegate: AnyObject {
    func selectedAirport(_ view: SelectAirportViewController, origin: OriginAirport, airport: AirportModel)
}

enum SearchStateSection {
    case content([AirportModel])
    case empty
}

enum OriginAirport {
    case origin
    case destination
}

final class SelectAirportViewController: BaseViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var airportTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Variables
    
    private var airports: AirportsModel?
    private var orderedAirports: [AirportModel] = []
    private lazy var filteredAirports = [AirportModel]()
    private var origin: OriginAirport = .origin
    private var searchSection: [SearchStateSection] = []
    
    private weak var delegate: SelectAirportDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureTableView()
        registerNotification()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        airportTextField.autocorrectionType = .no
        switch origin {
        case .origin:
            titleLabel.text = "Select station origin"
        case .destination:
            titleLabel.text = "Select station destination"
        }
        
        airportTextField.attributedPlaceholder = NSAttributedString(string: "Search station",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "AirportCell", bundle: nil), forCellReuseIdentifier: "AirportCell")
        tableView.register(UINib(nibName: "EmptyAirportCell", bundle: nil), forCellReuseIdentifier: "EmptyAirportCell")
        
        tableView.reloadData()
    }
    
    @IBAction func dismissSelectAirportView(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func registerNotification() {
        let nc = NotificationCenter.default
        
        nc.addObserver(self,
                       selector: #selector(didChangeNotification),
                       name: UITextField.textDidChangeNotification,
                       object: self.airportTextField)
        
        nc.addObserver(self,
                       selector: #selector(keyboardWillShow),
                       name: UIResponder.keyboardWillShowNotification,
                       object: nil)

        nc.addObserver(self,
                       selector: #selector(keyboardWillHide),
                       name: UIResponder.keyboardWillHideNotification,
                       object: nil)
    }
    
    @objc fileprivate func didChangeNotification(notification: Notification) {
        guard let textField = notification.object as? UITextField else { return }
        
        if let text = textField.text, !text.isEmpty {
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
        } else {
            filteredAirports = orderedAirports
            searchSection = [.content(filteredAirports)]
        }
        
        tableView.reloadData()
    }
    
    @objc fileprivate func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification:Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Public Methods
    
    public func configure(_ airports: AirportsModel, origin: OriginAirport, delegate: SelectAirportDelegate) {
        self.orderedAirports = airports.stations.sorted { ($0.countryName ?? "", $0.name ?? "") < ($1.countryName ?? "", $1.name ?? "") }
        self.origin = origin
        self.delegate = delegate
        self.filteredAirports = orderedAirports
        self.searchSection = [.content(filteredAirports)]
    }
}

extension SelectAirportViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchSection[section] {
        case .content(let airports):
            return airports.count
        case .empty:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch searchSection[indexPath.section] {
        case .content(let airports):
            let airport = airports[indexPath.row]
            return buildAirportCell(indexPath, airport: airport)
        case .empty:
            return buildEmptyCell(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch searchSection[indexPath.section] {
        case .content(let airports):
            let airport = airports[indexPath.row]
            
            dismiss(animated: true) {
                self.delegate?.selectedAirport(self, origin: self.origin, airport: airport)
            }
        case .empty:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch searchSection[indexPath.section] {
        case .empty:
            return 200.0
        case .content:
            return UITableView.automaticDimension
        }
    }
}

extension SelectAirportViewController {
    private func buildAirportCell(_ indexPath: IndexPath, airport: AirportModel) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AirportCell", for: indexPath) as? AirportCell else { return UITableViewCell() }
        
        cell.configure(name: airport.name, countryName: airport.countryName, code: airport.code)
        
        return cell
        
    }
    
    private func buildEmptyCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyAirportCell", for: indexPath)
        
        return cell
    }
}
