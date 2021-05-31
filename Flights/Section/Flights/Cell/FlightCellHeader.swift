//
//  FlightCellHeader.swift
//  Flights
//
//  Created by Tiago Oliveira on 30/05/21.
//

import UIKit

class FlightCellHeader: UITableViewHeaderFooterView {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Public Methods
    
    public func configure(_ title: String) {
        self.titleLabel.text = title
    }

    // MARK: - Memory Managements
    
    deinit {
        debugPrint("Deinit FlightCellHeader")
    }
}
