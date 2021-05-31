//
//  DateFormatter.swift
//  Flights
//
//  Created by Tiago Oliveira on 31/05/21.
//

import Foundation

public extension DateFormatter {
    static let iso3339: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
