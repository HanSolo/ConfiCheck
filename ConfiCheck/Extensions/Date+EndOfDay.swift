//
//  Date+EndOfDay.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 18.02.25.
//

import Foundation


extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }

    func endOfDay() -> Date {        
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
}

