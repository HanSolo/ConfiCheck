//
//  JsonData.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 10.02.25.
//

import Foundation


class JsonData: Codable {
    var name    : String?
    var date    : Double?
    var cfp     : Double?
    var country : String?

    
    private enum CodingKeys: String, CodingKey {
        case name    = "name"
        case date    = "date"
        case cfp     = "cfp"
        case country = "country"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name    = try? container.decode(String.self, forKey: .name)
        date    = try? container.decode(Double.self, forKey: .date)
        cfp     = try? container.decode(Double.self, forKey: .cfp)
        country = try? container.decode(String.self, forKey: .country)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(name,    forKey: .name)
        try? container.encode(date,    forKey: .date)
        try? container.encode(cfp,     forKey: .cfp)
        try? container.encode(country, forKey: .country)
    }
    
  
    public func getConference() -> Conference? {
        if nil == name { return nil }
        let conference : Conference = Conference(name: name!, date: Date.init(timeIntervalSince1970: date!), cfp: Date.init(timeIntervalSince1970: cfp!), country: country!)
        return conference
    }
}
