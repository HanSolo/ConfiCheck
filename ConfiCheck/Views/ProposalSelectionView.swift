//
//  ProposalSelection.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 29.01.25.
//

import Foundation
import SwiftUI


struct ProposalSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject      private var model : ConfiModel
    @State private var proposals : [ProposalItem]
    @State private var selection : ProposalItem?

    
    init(proposals: [ProposalItem]? = []) {
        self.proposals = proposals!
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                List(self.proposals, id: \.self, selection: $selection) { proposal in
                    Text("\(proposal.title)")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.primary)
                }
                .selectionDisabled(false)
                Spacer()
            }
            .navigationTitle("Proposal Selection")
            .toolbar(content: {
                ToolbarItem(placement: .bottomBar) {
                    Button("Add") {
                        self.model.selectedProposal = self.selection
                        dismiss()
                    }
                    .padding()
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                }
            })
        }
    }
}
