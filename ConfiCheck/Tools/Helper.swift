//
//  Helper.swift
//  Confi
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import Foundation
import SwiftUI
import PhotosUI


public struct Helper {
    private static var calendar : Calendar = .current
    
    
    public static func getDatesFromJavaConferenceDate(date: String) -> (Date?,Date?) {        
        if let result = try? Constants.JAVA_CONFERENCE_DATE_REGEX.wholeMatch(in: date) {
            if result.1 != nil {
                let day1   : Int = Int(result.2!)!
                let month1 : Int = getMonthFromName(month: result.3!.lowercased())
                let year   : Int = Int(result.4!)!
                if month1 == -1 { return (nil,nil) }
                var dateComponents : DateComponents = DateComponents()
                dateComponents.day   = day1
                dateComponents.month = month1
                dateComponents.year  = year
                return (calendar.date(from: dateComponents),nil)
            } else if result.5 != nil {
                let day1   : Int = Int(result.6!)!
                let day2   : Int = Int(result.7!)!
                let month1 : Int = getMonthFromName(month: result.8!.lowercased())
                let year   : Int = Int(result.9!)!
                if month1 == -1 { return (nil,nil) }
                var dateComponents1 : DateComponents = DateComponents()
                dateComponents1.day   = day1
                dateComponents1.month = month1
                dateComponents1.year  = year
                var dateComponents2 : DateComponents = DateComponents()
                dateComponents2.day   = day2
                dateComponents2.month = month1
                dateComponents2.year  = year
                return (calendar.date(from: dateComponents1),calendar.date(from: dateComponents2))
            } else if result.10 != nil {
                let day1   : Int = Int(result.11!)!
                let month1 : Int = getMonthFromName(month: result.12!.lowercased())
                let day2   : Int = Int(result.13!)!
                let month2 : Int = getMonthFromName(month: result.14!.description.lowercased())
                let year   : Int = Int(result.15!)!
                if month1 == -1 || month2 == -1 { return (nil,nil) }
                var dateComponents1 : DateComponents = DateComponents()
                dateComponents1.day   = day1
                dateComponents1.month = month1
                dateComponents1.year  = year
                var dateComponents2 : DateComponents = DateComponents()
                dateComponents2.day   = day2
                dateComponents2.month = month2
                dateComponents2.year  = year
                return (calendar.date(from: dateComponents1), calendar.date(from: dateComponents2))
            }
        } else {
            return (nil,nil)
        }
        return (nil,nil)
    }
        
    public static func getMonthFromName(month: String) -> Int {
        switch month {
            case "january", "jan"   : return 1
            case "february", "feb"  : return 2
            case "march", "mar"     : return 3
            case "april", "apr"     : return 4
            case "may"              : return 5
            case "june", "jun"      : return 6
            case "july", "jul"      : return 7
            case "august", "aug"    : return 8
            case "september", "sep" : return 9
            case "october", "oct"   : return 10
            case "november", "nov"  : return 11
            case "december", "dec"  : return 12
            default                 : return -1
        }
    }
    
    public static func datesToString(dates: (Date?,Date?)) -> String {
        if dates.0 == nil && dates.1 == nil { return "" }
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        if dates.1 != nil {
            if dates.0!.month == dates.1!.month {
                return "\(dates.0!.month)-\(formatter.string(from: dates.1!))"
            }
        }
        return "\(formatter.string(from: dates.0!))\(dates.1 != nil ? " - " : "")\(dates.1 != nil ? formatter.string(from:dates.1!) : "")"
    }
    
    public static func getLocationFromEventItem(text: String) -> String {        
        if let result = try? Constants.EVENT_ITEM_LOCATION_REGEX.wholeMatch(in: text) {
            return String(result.2)
        }
        return ""
    }

    public static func getCityFromEventItem(text: String) -> String {
        if text.isEmpty { return "" }
        let token : [String] = text.components(separatedBy: Constants.CITY_DELIMITER)
        return token[0].trimmingCharacters(in: .whitespaces)
    }
    
    public static func getCountryFromEventItem(text: String) -> String {
        if let result = try? Constants.EVENT_ITEM_COUNTRY_REGEX.wholeMatch(in: text) {
            return String(result.3)
        }
        return ""
    }
    
    public static func getDateFromItem(text: String) -> Date {
        if let result = try? Constants.EVENT_ITEM_DATE_REGEX.wholeMatch(in: text) {
            let day   : Int = Int(result.5)!
            let month : Int = getMonthFromName(month: result.4.lowercased())
            let year  : Int = Int(result.6)!
            var dateComponents : DateComponents = DateComponents()
            dateComponents.day   = day
            dateComponents.month = month
            dateComponents.year  = year
            return calendar.date(from: dateComponents)!
        }
        return Date(timeIntervalSince1970: 0)
    }

    public static func getColorForCfpDate(date: Date) -> Color {
        let now : Date = Date.now
        let diffs = calendar.dateComponents([.year, .month, .day], from: now, to: date)
        
        if diffs.month! < 0 && diffs.day! <= 0 {
            return Constants.GRAY
        } else if  diffs.month! == 0 && diffs.day! < 0 {
            return Constants.GRAY
        } else if diffs.month! == 0 && diffs.day! > 21 {
            return Constants.YELLOW
        } else if diffs.month! == 0 && diffs.day! > 14 {
            return Constants.ORANGE
        } else if diffs.month! == 0 && diffs.day! <= 7 {
            return Constants.RED
        } else {            
            return Constants.GREEN
        }
    }
    
    public static func isCfpOpen(date: Date) -> Bool {
        let now : Date = Date.now
        let diffs = calendar.dateComponents([.year, .month, .day], from: now, to: date)
        
        if diffs.month! <= 0 && diffs.day! <= 0 {
            return false
        } else {
            return true
        }
    }
    
    public static func profileImageExists(year: Int) -> Bool {
        let fileManager : FileManager = FileManager.default
        let url         : URL         = FileManager.documentsDirectory.appendingPathComponent(Constants.PROFILE_IMAGE_NAME)
        return fileManager.fileExists(atPath: url.path())
    }
    
    public static func saveProfileImage(image: UIImage) -> Void {
        Task {
            let fileManager : FileManager = FileManager.default
            if let data : Data = image.pngData() {
                if let imgBookmark = Data(base64Encoded: Properties.instance.imgBookmark!.data(using: .utf8)!) {
                    var isStale : Bool = false
                    do {
                        let resolvedUrl = try URL(resolvingBookmarkData: imgBookmark, options: [.withoutUI], bookmarkDataIsStale: &isStale)
                        //debugPrint(resolvedUrl.path)
                        do {
                            try fileManager.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: resolvedUrl.path)
                            //debugPrint("Successfully set file protection")
                        } catch {
                            debugPrint("Failed to set file protection. Error: \(error.localizedDescription)")
                        }
                        //if resolvedUrl.startAccessingSecurityScopedResource() {
                            do {
                                try data.write(to: resolvedUrl, options: [.atomic, .noFileProtection])
                                //debugPrint("Successfully saved img file via imgBookmark")
                                
                                if let bookmark = try? resolvedUrl.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil) {
                                    Properties.instance.imgBookmark = bookmark.base64EncodedString()
                                    //debugPrint("Successfully saved img bookmark to properties")
                                }
                            } catch {
                                debugPrint("Error saving img file. Error: \(error.localizedDescription)")
                            }
                        //}
                        do { resolvedUrl.stopAccessingSecurityScopedResource() }
                    } catch let error {
                        debugPrint("Error resolving URL from bookmark data. Error: \(error.localizedDescription)")
                                                                
                        let url : URL = FileManager.documentsDirectory.appendingPathComponent(Constants.PROFILE_IMAGE_NAME)
                        //let url : URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.APP_GROUP_ID)!.appendingPathComponent(Constants.PROFILE_IMAGE_NAME)
                        
                        do {
                            try fileManager.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: url.path)
                            //debugPrint("Successfully set file protection")
                        } catch {
                            debugPrint("Failed to set file protection. Error: \(error.localizedDescription)")
                        }
                        
                        do {
                            try data.write(to: url, options: [.atomic, .noFileProtection])
                            //debugPrint("Successfully saved img file")
                            
                            if let bookmark = try? url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil) {
                                Properties.instance.imgBookmark = bookmark.base64EncodedString()
                                //debugPrint("Successfully saved img bookmark to properties")
                            }
                        } catch {
                            debugPrint("Error saving img file. Error: \(error.localizedDescription)")
                        }
                    }
                } else {
                    let url: URL = FileManager.documentsDirectory.appendingPathComponent(Constants.PROFILE_IMAGE_NAME)
                    //let url : URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.APP_GROUP_ID)!.appendingPathComponent(Constants.PROFILE_IMAGE_NAME)
                    
                    do {
                        try fileManager.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: url.path)
                        //debugPrint("Suceessfully set file protection")
                    } catch {
                        debugPrint("Failed to set file protection. Error: \(error.localizedDescription)")
                    }
                    
                    do {
                        try data.write(to: url, options: [.atomic, .noFileProtection])
                        //debugPrint("Successfully saved img file")
                        
                        if let bookmark = try? url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil) {
                            Properties.instance.imgBookmark = bookmark.base64EncodedString()
                            //debugPrint("Successfully saved img bookmark to properties")
                        }
                    } catch {
                        debugPrint("Error saving img file. Error: \(error.localizedDescription)")
                    }
                }
            } else {
                debugPrint("Error decoding image data")
            }
        }
    }
    
    public static func loadProfileImage() -> Image? {
        let fileManager : FileManager = FileManager.default
        var image       : Image?
                
        if let imgBookmark = Data(base64Encoded: Properties.instance.imgBookmark!.data(using: .utf8)!) {
            var isStale : Bool = false
            do {
                let resolvedUrl = try URL(resolvingBookmarkData: imgBookmark, options: [.withoutUI], bookmarkDataIsStale: &isStale)
                
                do {
                    try fileManager.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: resolvedUrl.path)
                } catch {
                    debugPrint("Failed to set file protection. Error: \(error.localizedDescription)")
                }
                
                if resolvedUrl.startAccessingSecurityScopedResource() {
                    let uiImage : UIImage? = UIImage(contentsOfFile: resolvedUrl.path())
                    if uiImage != nil {
                        image = Image(uiImage: uiImage!)
                    } else {
                        debugPrint("Error reading img file from resolvedUrl")
                    }
                }
                do { resolvedUrl.stopAccessingSecurityScopedResource() }
            } catch let error {
                debugPrint("Error resolving URL from bookmark data. Error: \(error.localizedDescription)")
            }
        } else {
            let url : URL = FileManager.documentsDirectory.appendingPathComponent(Constants.PROFILE_IMAGE_NAME)
            //let url : URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.APP_GROUP_ID)!.appendingPathComponent(Constants.PROFILE_IMAGE_NAME)
            
            do {
                try fileManager.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: url.path)
            } catch {
                debugPrint("Failed to set file protection. Error: \(error.localizedDescription)")
            }
            
            let uiImage : UIImage? = UIImage(contentsOfFile: url.path())
            if uiImage != nil {
                image = Image(uiImage: uiImage!)
            } else {
                debugPrint("Error reading img file")
            }
        }
        return image
    }
    
    public static func loadProfileUIImage() -> UIImage? {
        let fileManager : FileManager = FileManager.default
        var image       : UIImage?
          
        /*
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
            DispatchQueue.main.async { [unowned self] in
                showUI(for: status)
            }
        }
        */
        
        if let imgBookmark = Data(base64Encoded: Properties.instance.imgBookmark!.data(using: .utf8)!) {
            var isStale : Bool = false
            do {
                let resolvedUrl = try URL(resolvingBookmarkData: imgBookmark, options: [.withoutUI], bookmarkDataIsStale: &isStale)
                
                do {
                    try fileManager.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: resolvedUrl.path)
                } catch {
                    //debugPrint("Failed to set file protection. Error: \(error.localizedDescription)")
                }
                
                if resolvedUrl.startAccessingSecurityScopedResource() {
                    let uiImage : UIImage? = UIImage(contentsOfFile: resolvedUrl.path())
                    if uiImage != nil {
                        return uiImage!
                        //image = uiImage!
                    } else {
                        //debugPrint("Error reading img file from resolvedUrl")
                    }
                }
                do { resolvedUrl.stopAccessingSecurityScopedResource() }
            } catch let error {
                //debugPrint("Error resolving URL from bookmark data. Error: \(error.localizedDescription)")
            }
        } else {
            let url : URL = FileManager.documentsDirectory.appendingPathComponent(Constants.PROFILE_IMAGE_NAME)
            //let url : URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.APP_GROUP_ID)!.appendingPathComponent(Constants.PROFILE_IMAGE_NAME)
            
            do {
                try fileManager.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: url.path)
            } catch {
                //debugPrint("Failed to set file protection. Error: \(error.localizedDescription)")
            }
            
            let uiImage : UIImage? = UIImage(contentsOfFile: url.path())
            if uiImage != nil {
                image = uiImage!
            } else {
                //debugPrint("Error reading img file")
            }
        }
        return image
    }
}
