//
//  ProposalsView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 27.01.25.
//

import Foundation
import SwiftUI
import SwiftData

struct ProposalsView: View {
    @Environment(\.dismiss)      private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme)  private var colorScheme
    @EnvironmentObject           private var model     : ConfiModel
    
    //let proposals: [ProposalItem]
    @State var filtered               : [ProposalItem] = []
    @State var addProposalViewVisible : Bool           = false
        
    private let pasteBoard = UIPasteboard.general
    
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        self.addProposalViewVisible = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(self.colorScheme == .dark ? .white : .black)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                    }
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Button("Close") {
                        dismiss()
                    }
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                }
                
                HStack {
                    Spacer()
                    Text("Proposals")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                    Spacer()
                }
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                
                
                List {
                    ForEach(filtered, id:\.self) { proposal in
                        NavigationLink(value: proposal) {
                            VStack(alignment: .leading, spacing: 20) {
                                Divider()
                                HStack {
                                    Text("Title")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    Button {
                                        pasteBoard.string = proposal.title
                                    } label: {
                                        Label("", systemImage: "document.on.document")
                                            .font(.system(size: 10, weight: .light, design: .rounded))
                                    }
                                    .foregroundStyle(.primary)
                                    .frame(minWidth: 16, maxWidth: 16)
                                }
                                
                                Text(proposal.title)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .multilineTextAlignment(.leading)
                                
                                
                                HStack {
                                    Text("Abstract")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                     
                                    Spacer()
                                     
                                    Button {
                                        pasteBoard.string = proposal.abstract
                                    } label: {
                                        Label("", systemImage: "document.on.document")
                                            .font(.system(size: 10, weight: .light, design: .rounded))
                                    }
                                    .foregroundStyle(.primary)
                                    .frame(minWidth: 16, maxWidth: 16)
                                }
                                Text(proposal.abstract)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .listRowBackground(self.colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(red: 0.9, green: 0.9, blue: 0.9))
                    }
                    .onDelete(perform: deleteProposal)
                }
                .scrollContentBackground(.hidden)
                .background(self.colorScheme == .dark ? .black : .white)
                .navigationDestination(for: ProposalItem.self) { proposal in
                    ProposalDetailsView(proposal: proposal)
                }
                .foregroundStyle(self.colorScheme == .dark ? .white : .black)
                
                Spacer()
            }
            .background(self.colorScheme == .dark ? .black : .white)
        }
        .accentColor(.primary)
        .sheet(isPresented: $addProposalViewVisible) {
            AddProposalView()
        }
        .onAppear(perform: loadItemsFromCloudKit)
        /*
        task {
            self.filtered = self.model.proposals
        }
        */
    }
    
    private func deleteProposal(indexSet: IndexSet) {
        indexSet.forEach { index in
            let proposal = self.model.proposals[index]
            context.delete(proposal)
            self.filtered.removeAll(where: { $0 == proposal })
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // CloudKit related functions
    private func storeItemsToCloudKit() -> Void {
        // Upload Items to CloudKit if not already happened today
        do {
            if self.model.proposals.count > 0 {
                for proposal in self.model.proposals {
                    context.insert(proposal)
                }
                try context.save()
                debugPrint("Proposals saved to CloudKit")
            } else {
                debugPrint("No conferences loaded -> not saved")
            }
        } catch {
            debugPrint(error)
        }
    }
    private func loadItemsFromCloudKit() -> Void {
        // Conference Items
        self.model.proposals.removeAll()
        let requestProposals = FetchDescriptor<ProposalItem>()
        let proposalItems : [ProposalItem] = try! context.fetch(requestProposals)
        if !proposalItems.isEmpty {
            if self.model.proposals.isEmpty {
                for proposal in proposalItems {
                    self.model.proposals.append(proposal)
                }
            }
        }
        debugPrint("\(proposalItems.count) proposal items loaded from CloudKit")
        self.model.proposals = self.model.proposals.uniqueElements()
                                        
        // Remove duplicates if needed
        if proposalItems.count != self.model.proposals.count {
            removeDuplicatesFromCloudKit()
        }
        
        self.filtered = self.model.proposals
    }
    private func removeDuplicatesFromCloudKit() -> Void {
        resetAllItems()
        let cleanedUpProposalItems : [ProposalItem] = self.model.proposals.uniqueElements()
        
        do {
            for proposalItem in cleanedUpProposalItems {
                context.insert(proposalItem)
            }
            
            try context.save()
            debugPrint("Removed duplicates from CloudKit")
        } catch {
            debugPrint("Error removing duplicates from CloudKit. \(error)")
        }
    }
    private func resetAllItems() -> Void {
        do {
            try context.delete(model: ProposalItem.self)
            debugPrint("Reset all items")
        } catch {
            debugPrint("Error resetting all items. \(error)")
        }
    }
}
