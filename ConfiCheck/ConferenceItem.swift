//
//  ConferenceItem.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import Foundation
import SwiftData

@Model
final class ConferenceItem: Identifiable, Equatable, Hashable, ObservableObject {    
    var name           : String  = ""
    var location       : String  = ""
    var city           : String  = ""
    var country        : String  = ""
    var url            : String  = ""
    var date           : Date    = Date.now
    var days           : Double  = 0.0
    var type           : String  = ""
    var cfpUrl         : String?
    var cfpDate        : String?
    var lat            : Double?
    var lon            : Double?
    var proposals      : [ProposalItem]?
    var proposalStates : [String:String]?
    
    
    init(name: String, location: String, city: String, country: String, url: String, date: Date, days: Double, type: String, cfpUrl: String? = "", cfpDate: String? = "", lat: Double? = 0.0, lon: Double? = 0.0, proposals: [ProposalItem]? = [], proposalStates: [String:String]? = [:]) {
        self.name           = name
        self.location       = location
        self.city           = city
        self.country        = country
        self.url            = url
        self.date           = date
        self.days           = days
        self.type           = type
        self.cfpUrl         = cfpUrl!
        self.cfpDate        = cfpDate!
        self.lat            = lat!
        self.lon            = lon!
        self.proposals      = proposals!
        self.proposalStates = proposalStates!
    }
        
    
    public func addProposal(proposal: ProposalItem) -> Void {
        if self.proposals == nil { self.proposals = [] }
        if !self.proposals!.contains(where: { $0.title == proposal.title }) {
            self.proposals!.append(proposal)            
            if self.proposalStates == nil { self.proposalStates = [:] }
            self.proposalStates![proposal.id] = Constants.ProposalStatus.notSubmitted.apiString            
        }        
    }
    public func removeProposal(proposal: ProposalItem) -> Void {        
        if self.proposals == nil { return }
        let proposalFound : ProposalItem? = self.proposals!.filter({ $0.title == proposal.title}).first
        if proposalFound != nil {
            let indexToRemove : Int = self.proposals!.firstIndex(of: proposalFound!)!
            self.proposals!.remove(at: indexToRemove)
            if self.proposalStates == nil { return }
            if self.proposalStates!.keys.contains(proposal.id) {
                self.proposalStates!.removeValue(forKey: proposal.id)
            }
        }
    }
    
    public func toString() -> String {
        return "\(name) -> proposals: \(self.proposals?.count ?? -1)"
    }
    
    
    var id: String {
        return "\(name)_\(url)_\(cfpDate ?? "-")"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(name)
        hasher.combine(cfpDate)
    }
    
    static func == (lhs: ConferenceItem, rhs: ConferenceItem) -> Bool {
        return lhs.name == rhs.name && lhs.url == rhs.url && lhs.cfpDate == rhs.cfpDate
    }
}
