//
//  ConfiModel.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import Foundation
import SwiftUI


@MainActor
public class ConfiModel: ObservableObject {
    @Published var networkMonitor          : NetworkMonitor           = NetworkMonitor()
    @Published var conferences             : [ConferenceItem]         = []
    @Published var conferencesPerMonth     : [Int : [ConferenceItem]] = [:]
    @Published var conferencesPerContinent : [Int : [ConferenceItem]] = [:] {
        didSet {
            self.conferencesWithOpenCfp.removeAll()
            var tmp : [Int : [ConferenceItem]] = [:]
            for month in self.conferencesPerContinent.keys {
                if self.conferencesPerContinent[month]?.isEmpty ?? true { continue }
                tmp[month] = self.conferencesPerContinent[month]?.filter({ $0.cfpDate != nil })
                                                                 .filter({ Helper.getDatesFromJavaConferenceDate(date: $0.cfpDate!).0 != nil })
                                                                 .filter({ Helper.isCfpOpen(date: Helper.getDatesFromJavaConferenceDate(date: $0.cfpDate!).0!) })
            }
            for month in tmp.keys {
                if tmp[month]?.isEmpty ?? true { continue }
                self.conferencesWithOpenCfp.append(contentsOf: tmp[month]!)
            }
        }
    }
    @Published var filteredConferences     : [Int : [ConferenceItem]] = [:]
    @Published var conferencesWithOpenCfp  : [ConferenceItem]         = []
    @Published var proposals               : [ProposalItem]           = []
    @Published var attendence              : [String : Int]           = Properties.instance.attendence ?? [:] {
        didSet {
            Properties.instance.attendence = self.attendence            
        }
    }
    @Published var selectedConference      : ConferenceItem?          = nil
    @Published var selectedProposal        : ProposalItem?            = nil
    @State     var update                  : Bool                     = false {
        didSet {
            self.conferencesPerMonth.removeAll()
            self.conferencesPerContinent.removeAll()
            self.filteredConferences.removeAll()
            for conference in self.conferences {                
                let month : Int = calendar.component(.month, from: conference.date)
                if !self.conferencesPerMonth.keys.contains(month) {
                    self.conferencesPerMonth[month]     = []
                    self.conferencesPerContinent[month] = []
                    self.filteredConferences[month]     = []
                }
                self.conferencesPerMonth[month]!.append(conference)
                self.conferencesPerContinent[month]!.append(conference)
                self.filteredConferences[month]!.append(conference)
            }
        }
    }
    
    let calendar : Calendar = Calendar.current
}
