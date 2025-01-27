//
//  Constants.swift
//  Confi
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import Foundation
import SwiftUI


public struct Constants {
    public static let APP_NAME                   : String = "ConfiCheck"
    public static let APP_GROUP_ID               : String = "group.eu.hansolo.ConfiCheck"
    public static let APP_REFRESH_ID             : String = "eu.hansolo.ConfiCheck.refresh"
    public static let APP_REFRESH_INTERVAL       : Double = 3600 // refresh app every 20 minutes in background
    public static let CANVAS_REFRESH_INTERVAL    : Double = 1
    public static let WIDGET_KIND                : String = "eu.hansolo.ConfiCheck.widget"
    
    public static let JAVA_CONFERENCES_JSON_URL  : String = "https://javaconferences.org/conferences.json"
    public static let DEVELOPER_EVENTS_JSON_URL  : String = "https://developers.events/feed-events.json"
    
    
    public static let JAVA_CONFERENCE_DATE_REGEX : Regex  = /(([0-9]{1,2})\s+([A-Za-z]+)\s+([0-9]{4}))|(([0-9]{1,2})[-–]([0-9]{1,2})\s+([a-zA-Z]+)\s+([0-9]{4}))|(([0-9]{1,2})\s+([a-zA-Z]+)\s-\s+([0-9]{1,2})\s([a-zA-Z]+)\s+([0-9]{4}))/
    public static let EVENT_ITEM_LOCATION_REGEX  : Regex  = /(@\s([a-zA-Z\s]+)\()/
    public static let EVENT_ITEM_CITY_REGEX      : Regex  = /([A-Za-z0-9\w\.\-\s]+),/
    public static let EVENT_ITEM_COUNTRY_REGEX   : Regex  = /(@\s([a-zA-Z\s]+)\(([a-zA-Z\s-]+)\))/
    public static let EVENT_ITEM_DATE_REGEX      : Regex  = /(\s-\s(([A-Za-z]{3})\s([A-Za-z]{3})\s([0-9]{1,2})\s([0-9]{4})))/
    
    public static let CITY_DELIMITER             : String = ","
    
    public static let PROFILE_IMAGE_NAME         : String = "ProfileImage"
    
    public static let GRAY                       : Color  = Color.gray
    public static let RED                        : Color  = Color(red: 0.996, green: 0.000, blue: 0.000, opacity: 1.00) // RGB 254,   0, 0
    public static let ORANGE                     : Color  = Color(red: 1.000, green: 0.365, blue: 0.004, opacity: 1.00) // RGB 255,  93, 0
    public static let YELLOW                     : Color  = Color(red: 1.000, green: 0.659, blue: 0.000, opacity: 1.00) // RGB 255, 168, 0
    public static let GREEN                      : Color  = Color(red: 0.000, green: 0.761, blue: 0.004, opacity: 1.00) //   0, 194, 1
    
    
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
    
    public enum AttendingStatus {
        case notAttending
        case attending
        case speaking
        
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
    
    public enum ProposalStatus {
        case notSubmitted
        case submitted
        case accepted
        case rejected
        
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
    }
}
