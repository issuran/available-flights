//
//  AlertViewController.swift
//  Flights
//
//  Created by Tiago Oliveira on 26/05/21.
//

import UIKit

class AlertViewController {
    func alertLoading() -> UIAlertController {
        let alert = UIAlertController(title: "Flights", message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 15, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        return alert
    }
    
    func alertError(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Flights", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction (title: "Ok!", style: .default, handler: nil)
        alert.addAction(okAction)

        return alert
    }
}
