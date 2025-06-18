//
//  Date+Components.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 18.06.25.
//

import Foundation


extension Date {
    func getDay() -> Int {
        return Calendar.current.component(.day,  from: self)
    }
    
    func getMonth() -> Int {
        return Calendar.current.component(.month,  from: self)
    }
    
    func getYear() -> Int {
        return Calendar.current.component(.year,  from: self)
    }
}
