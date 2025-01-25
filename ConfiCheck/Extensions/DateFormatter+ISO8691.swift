//
//  DateFormatter+ISO8691.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 26.12.24.
//

import Foundation


extension DateFormatter {
    static let fullISO8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar   = Calendar(identifier: .iso8601)
        formatter.timeZone   = TimeZone(secondsFromGMT: 0)
        //formatter.timeZone = .autoupdatingCurrent
        formatter.locale     = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
        
    static let fullISO8601_without_Z: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxx"
        formatter.calendar   = Calendar(identifier: .iso8601)
        formatter.timeZone   = TimeZone(secondsFromGMT: 0)
        formatter.locale     = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
