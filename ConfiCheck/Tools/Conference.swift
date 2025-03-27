//
//  Conference.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 10.02.25.
//

import Foundation

struct Conference : Identifiable {
    let name    : String
    let date    : Date
    let cfp     : Date
    let country : String
    let days    : Double
    
    
    var id: String {
        return "\(name)_\(country)"
    }
}
