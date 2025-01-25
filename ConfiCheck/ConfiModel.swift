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
    @Published var networkMonitor : NetworkMonitor   = NetworkMonitor()
    @Published var conferences    : [ConferenceItem] = []
    @Published var proposals      : [ProposalItem]   = []
    @Published var attendence     : [String : Int]   = Properties.instance.attendence ?? [:] {
        didSet {
            Properties.instance.attendence = self.attendence            
        }
    }
}
