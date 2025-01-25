//
//  Proposal.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 22.01.25.
//

import Foundation
import SwiftData

@Model
class ProposalItem {
    var title    : String
    var abstract : String
    var state    : String
    
    
    init(title : String, abstract : String, state : String) {
        self.title    = title
        self.abstract = abstract
        self.state    = state
    }
}
