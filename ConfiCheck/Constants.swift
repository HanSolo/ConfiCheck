//
//  Constants.swift
//  Confi
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import Foundation
import SwiftUI


public struct Constants {
    public static let APP_NAME                      : String = "ConfiCheck"
    public static let APP_GROUP_ID                  : String = "group.eu.hansolo.ConfiCheck"
    public static let CONTAINER_ID                  : String = "iCloud.eu.hansolo.ConfiCheckContainer"
    public static let APP_REFRESH_ID                : String = "eu.hansolo.ConfiCheck.refresh"
    public static let APP_REFRESH_INTERVAL          : Double = 3600 // refresh app every 20 minutes in background
    public static let CANVAS_REFRESH_INTERVAL       : Double = 10 // sec
    public static let WIDGET_KIND                   : String = "eu.hansolo.ConfiCheck.widget"
    
    public static let JAVA_CONFERENCES_JSON_URL     : String = "https://javaconferences.org/conferences.json"
    public static let DEVELOPER_EVENTS_JSON_URL     : String = "https://developers.events/feed-events.json"
    
    public static let CONFERENCES_THIS_MONTH_KEY_UD : String = "conferencesThisMonth"
    
    public static let JAVA_CONFERENCE_DATE_REGEX    : Regex  = /(([0-9]{1,2})\s+([A-Za-z]+)\s+([0-9]{4}))|(([0-9]{1,2})[-–]([0-9]{1,2})\s+([a-zA-Z]+)\s+([0-9]{4}))|(([0-9]{1,2})\s+([a-zA-Z]+)\s-\s+([0-9]{1,2})\s([a-zA-Z]+)\s+([0-9]{4}))/
    public static let EVENT_ITEM_LOCATION_REGEX     : Regex  = /(@\s([a-zA-Z\s]+)\()/
    public static let EVENT_ITEM_CITY_REGEX         : Regex  = /([A-Za-z0-9\w\.\-\s]+),/
    public static let EVENT_ITEM_COUNTRY_REGEX      : Regex  = /(@\s([a-zA-Z\s]+)\(([a-zA-Z\s-]+)\))/
    public static let EVENT_ITEM_DATE_REGEX         : Regex  = /(\s-\s(([A-Za-z]{3})\s([A-Za-z]{3})\s([0-9]{1,2})\s([0-9]{4})))/
    
    public static let CITY_DELIMITER                : String = ","
    
    public static let PROFILE_IMAGE_NAME            : String = "ProfileImage"
        
    public static let SECONDS_PER_HOUR              : Double = 3600
    public static let SECONDS_PER_DAY               : Double = 86400
    public static let SECONDS_PER_WEEK              : Double = 604800
    
    public static let GRAY                          : Color  = Color.gray
    public static let RED                           : Color  = Color(red: 0.996, green: 0.000, blue: 0.000, opacity: 1.00) // RGB 254,   0, 0
    public static let ORANGE                        : Color  = Color(red: 1.000, green: 0.365, blue: 0.004, opacity: 1.00) // RGB 255,  93, 0
    public static let YELLOW                        : Color  = Color(red: 1.000, green: 0.659, blue: 0.000, opacity: 1.00) // RGB 255, 168, 0
    public static let GREEN                         : Color  = Color(red: 0.000, green: 0.761, blue: 0.004, opacity: 1.00) //   0, 194, 1
    public static let PURPLE                        : Color  = Color(red: 0.620, green: 0.120, blue: 0.640, opacity: 1.00)
    
    public static let GC_BLACK                      : GraphicsContext.Shading = GraphicsContext.Shading.color(.black)
    public static let GC_WHITE                      : GraphicsContext.Shading = GraphicsContext.Shading.color(.white)
    public static let GC_GRAY                       : GraphicsContext.Shading = GraphicsContext.Shading.color(GRAY)
    public static let GC_RED                        : GraphicsContext.Shading = GraphicsContext.Shading.color(RED)
    public static let GC_ORANGE                     : GraphicsContext.Shading = GraphicsContext.Shading.color(ORANGE)
    public static let GC_YELLOW                     : GraphicsContext.Shading = GraphicsContext.Shading.color(YELLOW)
    public static let GC_GREEN                      : GraphicsContext.Shading = GraphicsContext.Shading.color(GREEN)
    public static let GC_PURPLE                     : GraphicsContext.Shading = GraphicsContext.Shading.color(PURPLE)

    
    
    // ******************** Enums *********************************************
    public enum ConferenceType {
        case inPerson
        case virtual
        case hybrid
        
        var uiString: String {
            switch self {
                case .inPerson: return "In-Person"
                case .virtual : return "Virtual"
                case .hybrid  : return "Hybrid"
            }
        }
        
        var apiString: String {
            switch self {
                case .inPerson: return "in_person"
                case .virtual : return "virtual"
                case .hybrid  : return "hybrid"
            }
        }
        
        public static func fromText(text: String) -> ConferenceType? {
            switch text {
            case "in-person" : return .inPerson
            case "virtual"   : return .virtual
            case "hybrid"    : return .hybrid
            default          : return nil
            }
        }
    }
    
    public enum AttendingStatus: String, CaseIterable {
        case notAttending
        case attending
        case speaking
        
        init?(id: Int) {
            switch id {
                case 0: self = .notAttending
                case 1: self = .attending
                case 2: self = .speaking
                default: return nil
            }
        }
        
        var uiString: String {
            switch self {
                case .notAttending : return "Not attending"
                case .attending    : return "Attending"
                case .speaking     : return "Speaking"
            }
        }
        
        var apiString: String {
            switch self {
                case .notAttending : return "not_attending"
                case .attending    : return "attending"
                case .speaking     : return "speaking"
            }
        }
        
        var color: Color {
            switch self {
                case .notAttending : return .secondary
                case .attending    : return .primary
                case .speaking     : return .green
            }
        }
            
        
        public static func fromText(text: String) -> AttendingStatus? {
            switch text {
                case "not_attending", "Not attending" : return .notAttending
                case "attending", "Attending"         : return .attending
                case "speaking", "Speaking"           : return .speaking
                default                               : return .notAttending
            }
        }
        
        public static func getIndexFromText(text: String) -> Int? {
            switch text {
                case "not_attending", "Not attending" : return 0
                case "attending", "Attending"         : return 1
                case "speaking", "Speaking"           : return 2
                default                               : return 0
            }
        }
        
        public static func getUiStrings() -> [String] {
            return [ AttendingStatus.notAttending.uiString, AttendingStatus.attending.uiString, AttendingStatus.speaking.uiString ]
        }
    }
    
    public enum ProposalStatus: String, Codable, CaseIterable {
        case notSubmitted
        case submitted
        case accepted
        case rejected
        
        init?(id: Int) {
            switch id {
                case 0: self = .notSubmitted
                case 1: self = .submitted
                case 2: self = .accepted
                case 3: self = .rejected
                default: return nil
            }
        }
        
        var uiString: String {
            switch self {
                case .notSubmitted : return "Not submitted"
                case .submitted    : return "Submitted"
                case .accepted     : return "Accepted"
                case .rejected     : return "Rejected"
            }
        }
        
        var apiString: String {
            switch self {
                case .notSubmitted : return "not_submitted"
                case .submitted    : return "submitted"
                case .accepted     : return "accepted"
                case .rejected     : return "rejected"
            }
        }
        
        var color: Color {
            switch self {
                case .notSubmitted : return .secondary
                case .submitted    : return .primary
                case .accepted     : return .green
                case .rejected     : return .red
            }
        }
        
        var index: Int {
            switch self {
                case .notSubmitted : return 0
                case .submitted    : return 1
                case .accepted     : return 2
                case .rejected     : return 3
            }
        }
        
        public static func fromText(text: String) -> ProposalStatus? {
            switch text {
                case "not_submitted", "Not sumbitted" : return .notSubmitted
                case "submitted", "Submitted"         : return .submitted
                case "accepted", "Accepted"           : return .accepted
                case "rejected", "Rejected"           : return .rejected
                default                               : return .notSubmitted
            }
        }
        
        public static func getIndexFromText(text: String) -> Int? {
            switch text {
                case "not_submitted", "Not sumbitted" : return 0
                case "submitted", "Submitted"         : return 1
                case "accepted", "Accepted"           : return 2
                case "rejected", "Rejected"           : return 3
                default                               : return 0
            }
        }
        
        public static func getUiStrings() -> [String] {
            return [ ProposalStatus.notSubmitted.uiString, ProposalStatus.submitted.uiString, ProposalStatus.accepted.uiString, ProposalStatus.rejected.uiString ]
        }
    }
    
    public enum Continent : String, CaseIterable {
        case all
        case africa
        case antarctica
        case asia
        case europe
        case northAmerica
        case oceania
        case southAmerica
        
        public var code: String {
            switch self {
                case .all          : return "ALL"
                case .africa       : return "AF"
                case .antarctica   : return "AN"
                case .asia         : return "AS"
                case .europe       : return "EU"
                case .northAmerica : return "NA"
                case .oceania      : return "OC"
                case .southAmerica : return "SA"
            }
        }
        
        public var name: String {
            switch self {
                case .all          : return "All Continents"
                case .africa       : return "Africa"
                case .antarctica   : return "Antarctica"
                case .asia         : return "Asia"
                case .europe       : return "Europe"
                case .northAmerica : return "North America"
                case .oceania      : return "Oceania"
                case .southAmerica : return "South America"
            }
        }
        
        public var index: Int {
            switch self {
                case .all          : return 0
                case .africa       : return 1
                case .antarctica   : return 2
                case .asia         : return 3
                case .europe       : return 4
                case .northAmerica : return 5
                case .oceania      : return 6
                case .southAmerica : return 7
            }
        }
    }
}
