//
//  Storage.swift
//  GlucoTracker
//
//  Created by Gerrit Grunwald on 01.08.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import SwiftUI
import os.log


extension Key {
    static let notificationsEnabled : Key = "notificationsEnabled"
    static let attendence           : Key = "attendence"
    static let speakerName          : Key = "speakerName"
    static let speakerBlueSky       : Key = "speakerBlueSky"
    static let speakerBio           : Key = "speakerBio"
    static let speakerExperience    : Key = "speakerExperience"
    static let imgBookmark          : Key = "imgBookmark"
    static let lastItemsSaved       : Key = "lastItemsSaved"
    static let selectedContinent    : Key = "selectedContinent"
}



// Define storage
public struct Properties {
    
    static var instance = Properties()
    
    @UserDefault(key: .notificationsEnabled, defaultValue: false)
    var notificationsEnabled: Bool?
    
    @UserDefault(key: .attendence, defaultValue: [:])
    var attendence: [String:Int]?
    
    @UserDefault(key: .speakerName, defaultValue: "")
    var speakerName: String?
    
    @UserDefault(key: .speakerBlueSky, defaultValue: "")
    var speakerBlueSky: String?
    
    @UserDefault(key: .speakerBio, defaultValue: "")
    var speakerBio: String?
    
    @UserDefault(key: .speakerExperience, defaultValue: "")
    var speakerExperience: String?
    
    @UserDefault(key: .imgBookmark, defaultValue: "")
    var imgBookmark: String?
    
    @UserDefault(key: .lastItemsSaved, defaultValue: 0.0)
    var lastItemsSaved: Double?
    
    @UserDefault(key: .selectedContinent, defaultValue: 0)
    var selectedContinent: Int?
    
    private init() {}
}
