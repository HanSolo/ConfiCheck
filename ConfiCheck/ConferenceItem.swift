//
//  ConferenceItem.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import Foundation
import SwiftData

@Model
final class ConferenceItem: Identifiable, Equatable, Hashable {
    var name           : String  = ""
    var location       : String  = ""
    var city           : String  = ""
    var country        : String  = ""
    var url            : String  = ""
    var date           : Date    = Date.now
    var type           : String  = ""
    var cfpUrl         : String?
    var cfpDate        : String?
    var lat            : Double?
    var lon            : Double?
    
    
    init(name: String, location: String, city: String, country: String, url: String, date: Date, type: String, cfpUrl: String? = "", cfpDate: String? = "", lat: Double? = 0.0, lon: Double? = 0.0) {
        self.name      = name
        self.location  = location
        self.city      = city
        self.country   = country
        self.url       = url
        self.date      = date
        self.type      = type
        self.cfpUrl    = cfpUrl!
        self.cfpDate   = cfpDate!
        self.lat       = lat!
        self.lon       = lon!
    }
        
    var id: String {
        return "\(name)_\(url)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(name)
    }
    
    static func == (lhs: ConferenceItem, rhs: ConferenceItem) -> Bool {
        return lhs.name == rhs.name && lhs.url == rhs.url
    }
}
