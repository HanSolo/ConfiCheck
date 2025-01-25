//
//  DeveloperEvent.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 16.01.25.
//

import Foundation


class DeveloperEvent: Codable {
    var items       : [Items]?
    var description : String?
    var feedUrl     : String?
    var version     : String?
    var author      : Author?
    var title       : String?
    var homePageUrl : String?

    private enum CodingKeys: String, CodingKey {
        case items       = "items"
        case description = "description"
        case feedUrl     = "feed_url"
        case version     = "version"
        case author      = "author"
        case title       = "title"
        case homePageUrl = "home_page_url"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items       = try? container.decode([Items].self, forKey: .items)
        description = try? container.decode(String.self, forKey: .description)
        feedUrl     = try? container.decode(String.self, forKey: .feedUrl)
        version     = try? container.decode(String.self, forKey: .version)
        author      = try? container.decode(Author.self, forKey: .author)
        title       = try? container.decode(String.self, forKey: .title)
        homePageUrl = try? container.decode(String.self, forKey: .homePageUrl)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(items,       forKey: .items)
        try? container.encode(description, forKey: .description)
        try? container.encode(feedUrl,     forKey: .feedUrl)
        try? container.encode(version,     forKey: .version)
        try? container.encode(author,      forKey: .author)
        try? container.encode(title,       forKey: .title)
        try? container.encode(homePageUrl, forKey: .homePageUrl)
    }
    
    public static func convertToConferenceItem(eventItem: Items) -> ConferenceItem {
        let name        : String  = eventItem.title!
        let location    : String  = Helper.getLocationFromEventItem(text: eventItem.contentHtml!)
        let cityName    : String  = Helper.getCityFromEventItem(text: eventItem.contentHtml!)
        let countryName : String  = Helper.getCountryFromEventItem(text: eventItem.contentHtml!)
        let type        : Constants.ConferenceType
        if countryName.lowercased() == "online" {
            type = .virtual
        } else {
            type = .inPerson
        }
        let date        : Date    = Helper.getDateFromItem(text: eventItem.contentHtml!)
        let city        : String  = type == .virtual ? "" : cityName
        let country     : String  = type == .virtual ? "" : countryName
        let url         : String  = eventItem.url ?? ""
        let cfpUrl      : String  = ""
        let cfpEndDate  : String  = ""
        let lat         : Double  = -1
        let lon         : Double  = -1
        
        return ConferenceItem(name: name, location: location, city: city, country: country, url: url, date: date, type: type.apiString, cfpUrl: cfpUrl, cfpDate: cfpEndDate, lat: lat, lon: lon)
    }
}

class Items: Codable {
    var id           : String?
    var contentHtml  : String?
    var url          : String?
    var title        : String?
    var summary      : String?
    var dateModified : String?
    var author       : Author?

    private enum CodingKeys: String, CodingKey {
        case id           = "id"
        case contentHtml  = "content_html"
        case url          = "url"
        case title        = "title"
        case summary      = "summary"
        case dateModified = "date_modified"
        case author       = "author"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id           = try? container.decode(String.self, forKey: .id)
        contentHtml  = try? container.decode(String.self, forKey: .contentHtml)
        url          = try? container.decode(String.self, forKey: .url)
        title        = try? container.decode(String.self, forKey: .title)
        summary      = try? container.decode(String.self, forKey: .summary)
        dateModified = try? container.decode(String.self, forKey: .dateModified)
        author       = try? container.decode(Author.self, forKey: .author)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(dateModified, forKey: .dateModified)
        try? container.encode(title,        forKey: .title)
        try? container.encode(id,           forKey: .id)
        try? container.encode(author,       forKey: .author)
        try? container.encode(summary,      forKey: .summary)
        try? container.encode(url,          forKey: .url)
        try? container.encode(contentHtml,  forKey: .contentHtml)
    }
}

class Author: Codable {
    var name : String?
    var url  : String?

    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case url  = "url"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try? container.decode(String.self, forKey: .name)
        url  = try? container.decode(String.self, forKey: .url)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(name, forKey: .name)
        try? container.encode(url,  forKey: .url)
    }
}
