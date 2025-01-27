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
    @Published var networkMonitor      : NetworkMonitor           = NetworkMonitor()
    @Published var conferences         : [ConferenceItem]         = []
    @Published var conferencesPerMonth : [Int : [ConferenceItem]] = [:]
    @Published var filteredConferences : [Int : [ConferenceItem]] = [:]
    @Published var proposals           : [ProposalItem]           = []
    @Published var attendence          : [String : Int]           = Properties.instance.attendence ?? [:] {
        didSet {
            Properties.instance.attendence = self.attendence            
        }
    }
    @State     var update              : Bool                     = false {
        didSet {
            self.conferencesPerMonth.removeAll()
            self.filteredConferences.removeAll()
            for conference in self.conferences {
                let month : Int = calendar.component(.month, from: conference.date)
                if !self.conferencesPerMonth.keys.contains(month) {
                    self.conferencesPerMonth[month] = []
                    self.filteredConferences[month] = []
                }
                self.conferencesPerMonth[month]!.append(conference)
                self.filteredConferences[month]!.append(conference)
            }
        }
    }
    
    let calendar : Calendar = Calendar.current
}
