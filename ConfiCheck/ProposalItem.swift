//
//  Proposal.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 22.01.25.
//

import Foundation
import SwiftData

@Model
final class ProposalItem: Identifiable, Equatable, Hashable {
    var title    : String = ""
    var abstract : String = ""
    var pitch    : String = ""
    
    
    init(title : String, abstract : String, pitch: String) {
        self.title    = title
        self.abstract = abstract
        self.pitch    = pitch
    }
    
    var id: String {
        return "\(title)_\(abstract)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(abstract)
    }
    
    static func == (lhs: ProposalItem, rhs: ProposalItem) -> Bool {
        return lhs.title == rhs.title
    }
}
