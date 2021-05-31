//
//  LoadingCell.swift
//  Flights
//
//  Created by Tiago Oliveira on 29/05/21.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Public Methods
    
    public func configure() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
    }
    
    // MARK: - Memory Managements
    
    deinit {
        debugPrint("Deinit AirportCell")
    }
}
