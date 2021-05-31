//
//  SearchViewController.swift
//  Flights
//
//  Created by Tiago Oliveira on 25/05/21.
//

import UIKit

enum PassengerTypeSection {
    case adults
    case teen
    case children
}

class SearchViewController: BaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var airportOriginTextField: UITextField!
    @IBOutlet private weak var airportDestinationTextField: UITextField!
    @IBOutlet private weak var adultsTextField: UITextField!
    @IBOutlet private weak var teenTextField: UITextField!
    @IBOutlet private weak var childrenTextField: UITextField!
    @IBOutlet private weak var dateTextField: UITextField!
    
    // MARK: - Variables
    
    private var viewModel: SearchViewModelProvider?
    private lazy var searchModel = FlightsSearchModel()
    
    let adultsPicker = UIPickerView()
    let teenPicker = UIPickerView()
    let childrenPicker = UIPickerView()
    let datePicker = UIDatePicker()
    
    var section: PassengerTypeSection = .adults
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SearchViewModel()
        setupView()
        setupDelegates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestAirports()
    }
    
    // MARK: - Action Methods
    
    @IBAction func didTapOnSearch(_ sender: Any) {
        performSegue(withIdentifier: "SearchViewControllerToFlightsViewController", sender: nil)
    }
    
    @IBAction func didTapOnOrigin(_ sender: Any) {
        performSegue(withIdentifier: "SearchViewControllerToSelectAirportViewController", sender: OriginAirport.origin)
    }
    
    @IBAction func didTapOnDestination(_ sender: Any) {
        performSegue(withIdentifier: "SearchViewControllerToSelectAirportViewController", sender: OriginAirport.destination)
    }
    
    // MARK: - Navigation Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchViewControllerToSelectAirportViewController",
           let vc = segue.destination as? SelectAirportViewController,
           let origin = sender as? OriginAirport,
           let airports = viewModel?.airports {
            vc.configure(airports, origin: origin, delegate: self)
        }
        
        if segue.identifier == "SearchViewControllerToFlightsViewController",
           let vc = segue.destination as? FlightsViewController {
            vc.configure(searchModel)
        }
    }
    
    // MARK: - Network Methods
    
    private func requestAirports() {
        let alert = AlertViewController()
        
        self.present(alert.alertLoading(), animated: true)
        viewModel?.requestAirports { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    if case let .failure(error) = result { self.handleAlerts(error.localizedDescription) }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        configureTextFields()
        configureDatePicker()
        createPassengersToolBar()
        createDateToolBar()
        configureRefreshControl()
        updateButton()
    }
    
    private func configureTextFields() {
        airportOriginTextField.attributedPlaceholder = NSAttributedString(string: "Select origin",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        airportDestinationTextField.attributedPlaceholder = NSAttributedString(string: "Select destination",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        dateTextField.attributedPlaceholder = NSAttributedString(string: "Select date",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        adultsTextField.text = "\(viewModel?.adultsPassenger.first ?? 1)"
        teenTextField.text = "\(viewModel?.teenPassenger.first ?? 0)"
        childrenTextField.text = "\(viewModel?.childrenPassenger.first ?? 0)"
        
        adultsTextField.inputView = adultsPicker
        teenTextField.inputView = teenPicker
        childrenTextField.inputView = childrenPicker
    }
    
    private func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        datePicker.addTarget(self,
                             action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        
        dateTextField.inputView = datePicker
    }
    
    private func setupDelegates() {
        adultsPicker.delegate = self
        teenPicker.delegate = self
        childrenPicker.delegate = self
        adultsPicker.dataSource = self
        teenPicker.dataSource = self
        childrenPicker.dataSource = self
        
        adultsTextField.delegate = self
        teenTextField.delegate = self
        childrenTextField.delegate = self
    }
    
    private func createPassengersToolBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolBar.barStyle = .default
        toolBar.tintColor = .gray
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePassengerButtonTapped))
        toolBar.setItems([doneButton], animated: false)
        adultsTextField.inputAccessoryView = toolBar
        teenTextField.inputAccessoryView = toolBar
        childrenTextField.inputAccessoryView = toolBar
    }
    
    private func createDateToolBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolBar.barStyle = .default
        toolBar.tintColor = .gray
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneDateButtonTapped))
        toolBar.setItems([doneButton], animated: false)
        dateTextField.inputAccessoryView = toolBar
    }
    
    private func configureRefreshControl() {
        scrollView.alwaysBounceVertical = true
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.tintColor = UIColor.accentColor()
        scrollView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    private func updateButton() {
        let isValid = searchModel.isValid()
        searchButton.isUserInteractionEnabled = isValid
        UIView.animate(withDuration: 0.35) {
            if isValid {
                self.searchButton.layer.backgroundColor = CGColor.accentColor()
            } else {
                self.searchButton.layer.backgroundColor = CGColor.buttonDisabled()
            }
        }
    }
    
    private func handleAlerts(_ message: String) {
        let alert = AlertViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.present(alert.alertError(message: message), animated: true)
        }
    }
    
    private func clearFields() {
        airportOriginTextField.text = nil
        airportDestinationTextField.text = nil
        dateTextField.text = nil
        
        searchModel.origin = nil
        searchModel.destination = nil
        searchModel.date = nil
        
        updateButton()
    }
    
    @objc func donePassengerButtonTapped() {
        self.adultsTextField.resignFirstResponder()
        self.teenTextField.resignFirstResponder()
        self.childrenTextField.resignFirstResponder()
    }
    
    @objc func doneDateButtonTapped() {
        self.dateTextField.resignFirstResponder()
        dateTextField.text = viewModel?.dateFormatter(datePicker.date)
        searchModel.date = datePicker.date
        updateButton()
    }
    
    @objc func datePickerChanged(sender: UIDatePicker) {
        dateTextField.text = viewModel?.dateFormatter(sender.date)
        searchModel.date = sender.date
        updateButton()
    }
    
    @objc func didPullToRefresh() {
        scrollView.refreshControl?.beginRefreshing()
        clearFields()
        
        viewModel?.requestAirports { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.scrollView.refreshControl?.endRefreshing()
                if case let .failure(error) = result { self.handleAlerts(error.localizedDescription) }
            }
        }
    }
    
    // MARK: - Deinit Method
    
    deinit {
        debugPrint("Deinit SearchViewController")
    }
}

extension SearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        switch section {
        case .adults:
            return viewModel.adultsPassenger.count
        case .teen:
            return viewModel.teenPassenger.count
        case .children:
            return viewModel.childrenPassenger.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let viewModel = viewModel else { return "" }
        switch section {
        case .adults:
            return "\(viewModel.adultsPassenger[row])"
        case .teen:
            return "\(viewModel.teenPassenger[row])"
        case .children:
            return "\(viewModel.childrenPassenger[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let viewModel = viewModel else { return }
        switch section {
        case .adults:
            adultsTextField.text = "\(viewModel.adultsPassenger[row])"
            searchModel.adults = viewModel.adultsPassenger[row]
        case .teen:
            teenTextField.text = "\(viewModel.teenPassenger[row])"
            searchModel.teen = viewModel.teenPassenger[row]
        case .children:
            childrenTextField.text = "\(viewModel.childrenPassenger[row])"
            searchModel.children = viewModel.childrenPassenger[row]
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case teenTextField:
            section = .teen
        case childrenTextField:
            section = .children
        default:
            section = .adults
        }
    }
}

extension SearchViewController: SelectAirportDelegate {
    func selectedAirport(_ view: SelectAirportViewController, origin: OriginAirport, airport: AirportModel) {
        switch origin {
        case .origin:
            airportOriginTextField.text = "\(airport.name ?? "") - \(airport.code ?? "")"
            searchModel.origin = airport.code
            updateButton()
        case .destination:
            airportDestinationTextField.text = "\(airport.name ?? "") - \(airport.code ?? "")"
            searchModel.destination = airport.code
            updateButton()
        }
    }
}
