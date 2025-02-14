//
//  JavaConference.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 16.01.25.
//

import Foundation


class JavaConference: Codable {
    var cfpEndDate   : String?
    var coordinates  : Coordinates?
    var locationName : String?
    var hybrid       : Bool?
    var cfpLink      : String?
    var date         : String?
    var name         : String?
    var link         : String?

    private enum CodingKeys: String, CodingKey {
        case cfpEndDate   = "cfpEndDate"
        case coordinates  = "coordinates"
        case locationName = "locationName"
        case hybrid       = "hybrid"
        case cfpLink      = "cfpLink"
        case date         = "date"
        case name         = "name"
        case link         = "link"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cfpEndDate   = try? container.decode(String.self,      forKey: .cfpEndDate)
        coordinates  = try? container.decode(Coordinates.self, forKey: .coordinates)
        locationName = try? container.decode(String.self,      forKey: .locationName)
        hybrid       = try? container.decode(Bool.self,        forKey: .hybrid)
        cfpLink      = try? container.decode(String.self,      forKey: .cfpLink)
        date         = try? container.decode(String.self,      forKey: .date)
        name         = try? container.decode(String.self,      forKey: .name)
        link         = try? container.decode(String.self,      forKey: .link)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(cfpEndDate,   forKey: .cfpEndDate)
        try? container.encode(coordinates,  forKey: .coordinates)
        try? container.encode(locationName, forKey: .locationName)
        try? container.encode(hybrid,       forKey: .hybrid)
        try? container.encode(cfpLink,      forKey: .cfpLink)
        try? container.encode(date,         forKey: .date)
        try? container.encode(name,         forKey: .name)
        try? container.encode(link,         forKey: .link)
    }
    
    public static func convertToConferenceItem(javaConference: JavaConference) -> ConferenceItem {
        let name        : String  = javaConference.name!
        let location    : String  = javaConference.locationName!
        let cityName    : String  = Helper.getCityFromEventItem(text: javaConference.locationName ?? "")
        let countryName : String  = javaConference.coordinates?.countryName ?? ""
        let type        : Constants.ConferenceType
        if countryName.lowercased() == "online" {
            type = .virtual
        } else if javaConference.hybrid! {
            type = .hybrid
        } else {
            type = .inPerson
        }
        let dates       : (Date?,Date?) = Helper.getDatesFromJavaConferenceDate(date: javaConference.date!)
        let date        : Date    = dates.0 ?? Date(timeIntervalSince1970: 0)
        let endDate     : Date    = dates.1 ?? date
        let days        : Double  = Double(Helper.getDaysBetweenDates(dateFrom: date, dateTo: endDate))
        let city        : String  = type == .virtual ? "ONLINE" : cityName
        let country     : String  = type == .virtual ? "" : countryName
        let url         : String  = javaConference.link ?? ""
        let cfpUrl      : String? = javaConference.cfpLink
        let cfpEndDate  : String  = javaConference.cfpEndDate ?? ""
        let lat         : Double? = javaConference.coordinates?.lat
        let lon         : Double? = javaConference.coordinates?.lon
        
        return ConferenceItem(name: name, location: location, city: city, country: country, url: url, date: date, days: days, type: type.apiString, cfpUrl: cfpUrl, cfpDate: cfpEndDate, lat: lat, lon: lon)
    }
}

class Coordinates: Codable {
    var lon         : Double?
    var countryName : String?
    var lat         : Double?

    private enum CodingKeys: String, CodingKey {
        case lat         = "lat"
        case lon         = "lon"
        case countryName = "countryName"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lat         = try? container.decode(Double.self, forKey: .lat)
        lon         = try? container.decode(Double.self, forKey: .lon)
        countryName = try? container.decode(String.self, forKey: .countryName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(lat,         forKey: .lat)
        try? container.encode(lon,         forKey: .lon)
        try? container.encode(countryName, forKey: .countryName)
    }
}
