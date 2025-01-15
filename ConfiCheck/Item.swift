//
//  Item.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
