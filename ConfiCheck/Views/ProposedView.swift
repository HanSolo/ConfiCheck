//
//  ProposedView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 28.01.25.
//

import SwiftUI

struct ProposedView: View {
    @Environment(\.modelContext) private var context
    @State var proposal                    : ProposalItem
    @State var conference                  : ConferenceItem
    @State var selectedProposalStatusIndex : Int = 0
            
    
    init(proposal: ProposalItem, conference: ConferenceItem) {
        self.proposal   = proposal
        self.conference = conference
    }
    
    
    var body: some View {
        HStack {
            Text("\(self.proposal.title)")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(.primary)
            Spacer()
            Menu {
                Picker(selection: $selectedProposalStatusIndex) {
                    Text("\(Constants.ProposalStatus.notSubmitted.uiString)").tag(0)
                    Text("\(Constants.ProposalStatus.submitted.uiString)").tag(1)
                    Text("\(Constants.ProposalStatus.accepted.uiString)").tag(2)
                    Text("\(Constants.ProposalStatus.rejected.uiString)").tag(3)
                } label: {}
            } label: {
                Text("\(Constants.ProposalStatus.getUiStrings()[self.selectedProposalStatusIndex])")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(Constants.ProposalStatus.allCases[self.selectedProposalStatusIndex].color)
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .onChange(of: self.selectedProposalStatusIndex) {
            self.conference.proposalStates![self.proposal.id] = Constants.ProposalStatus.allCases[self.selectedProposalStatusIndex].apiString
            do {
                try self.context.save()
            } catch {
                debugPrint("Error saving context: \(error)")
            }
        }
        .task {
            if self.conference.proposalStates?.keys.contains(proposal.id) ?? false {
                self.selectedProposalStatusIndex = Constants.ProposalStatus.fromText(text: self.conference.proposalStates![proposal.id]!)!.index
            }
        }
    }
}
