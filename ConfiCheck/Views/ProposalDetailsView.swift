//
//  ProposalDetailsView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 27.01.25.
//

import Foundation
import SwiftUI
import SwiftData


struct ProposalDetailsView: View {
    @Environment(\.colorScheme)          var colorScheme
    @EnvironmentObject                   var model : ConfiModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss
    
    @State private var title    : String = ""
    @State private var abstract : String = ""
    @State private var maxChars : Int   = 80

    let proposal: ProposalItem

    
    var body: some View {
        let text = Binding(
            get: { self.title },
            set: { self.title = String($0.prefix(self.maxChars))}
        )
        
        Form {
            VStack(alignment: .leading) {                
                Text("Title")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                TextField("Enter title", text: text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .cornerRadius(6)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .accentColor(.accentColor)
            }
            .background(self.colorScheme == .dark ? .black : .white)
            .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
            
            VStack(alignment: .leading) {                
                Text("Abstract")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                TextField("Enter abstract", text: $abstract, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .cornerRadius(6)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .accentColor(.accentColor)
            }
            .background(self.colorScheme == .dark ? .black : .white)
            .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
                        
            Button("Update") {
                proposal.title    = title
                proposal.abstract = abstract

                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
                
                dismiss()
            }
            .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
            .foregroundStyle(self.colorScheme == .dark ? .white : .black)
            .buttonStyle(.bordered)
        }
        .scrollContentBackground(.hidden)
        .background(self.colorScheme == .dark ? .black : .white)
        .onAppear {
            self.title    = proposal.title
            self.abstract = proposal.abstract            
        }
    }
}
