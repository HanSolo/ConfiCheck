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
}



// Define storage
public struct Properties {
    
    static var instance = Properties()
    
    @UserDefault(key: .notificationsEnabled, defaultValue: false)
    var notificationsEnabled: Bool?
    
    @UserDefault(key: .attendence, defaultValue: [:])
    var attendence: [String:Int]?
    
    private init() {}
}
