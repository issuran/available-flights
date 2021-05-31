//
//  UIColor+Extension.swift
//  Flights
//
//  Created by Tiago Oliveira on 27/05/21.
//

import UIKit

extension UIColor {
    class func accentColor() -> UIColor {
        return UIColor(red: 0.0, green: 0.18, blue: 0.65, alpha: 1)
    }
}

extension CGColor {
    class func buttonDisabled() -> CGColor {
        return UIColor(red: 0.86, green: 0.85, blue: 0.89, alpha: 1).cgColor
    }
    
    class func accentColor() -> CGColor {
        return UIColor(red: 0.0, green: 0.18, blue: 0.65, alpha: 1).cgColor
    }
}
