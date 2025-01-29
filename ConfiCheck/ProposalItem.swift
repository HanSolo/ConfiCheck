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
    @Relationship(inverse: \ConferenceItem.proposals) var conferences : [ConferenceItem]?
    
    
    init(title : String, abstract : String, pitch: String, conferences: [ConferenceItem]? = []) {
        self.title       = title
        self.abstract    = abstract
        self.pitch       = pitch
        self.conferences = conferences
    }
    
    var id: String {
        return "\(title)"
        //return "\(title)_\(abstract)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(abstract)
    }
    
    static func == (lhs: ProposalItem, rhs: ProposalItem) -> Bool {
        return lhs.title == rhs.title
    }
}
