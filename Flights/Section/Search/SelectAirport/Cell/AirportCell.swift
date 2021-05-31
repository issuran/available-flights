//
//  AirportCell.swift
//  Flights
//
//  Created by Tiago Oliveira on 26/05/21.
//

import UIKit

class AirportCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryNameLabel: UILabel!
    @IBOutlet private weak var codeLabel: UILabel!

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
        nameLabel.text = nil
        countryNameLabel.text = nil
        codeLabel.text = nil
    }
    
    // MARK: - Public Methods
    
    func configure(name: String?, countryName: String?, code: String?) {
        nameLabel.text = name
        countryNameLabel.text = countryName
        codeLabel.text = code
    }
    
    // MARK: - Memory Managements
    
    deinit {
        debugPrint("Deinit AirportCell")
    }
    
}
