//
//  Country.swift
//  CountryCounter
//
//  Created by Gerrit Grunwald on 21.08.24.
//

import Foundation


public class Country : Hashable, Identifiable {
    public  let id      : String
    public  let isoInfo : IsoCountryInfo
    
    
    init(isoInfo : IsoCountryInfo) {
        self.id      = isoInfo.alpha2
        self.isoInfo = isoInfo
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(isoInfo.alpha2)
    }
    
    public static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.isoInfo.alpha2 == rhs.isoInfo.alpha2 &&
               lhs.isoInfo.alpha3 == rhs.isoInfo.alpha3 &&
               lhs.isoInfo.name   == rhs.isoInfo.name
    }
}
