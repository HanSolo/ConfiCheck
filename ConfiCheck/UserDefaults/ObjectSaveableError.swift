//
//  ObjectSaveableError.swift
//  Navigator
//
//  Created by Gerrit Grunwald on 25.12.23.
//

import Foundation


enum ObjectSaveableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue        = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}
