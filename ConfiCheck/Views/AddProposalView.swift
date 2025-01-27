//
//  AddProposalView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 27.01.25.
//

import Foundation
import SwiftUI
import CoreLocation
import SwiftData
import Combine



struct AddProposalView: View {
    @Environment(\.colorScheme)          var colorScheme
    @EnvironmentObject                   var model : ConfiModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss
    
    @State private var title    : String = ""
    @State private var abstract : String = ""
    @State private var maxChars : Int    = 200

    
    private var isFormValid: Bool {
        return !self.title.isEmpty
    }
    

    var body: some View {
        let text = Binding(
            get: { self.title },
            set: { self.title = String($0.prefix(self.maxChars))}
        )
        
        NavigationStack {
            let bgColor : Color = self.colorScheme == .dark ? .black : .white
            
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .padding()
                .buttonStyle(.bordered)
                .foregroundStyle(.primary)
            }
            
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
                .listRowBackground(bgColor)
                
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
                .listRowBackground(bgColor)
                
                HStack {
                    Spacer()
                    
                    Button("Save") {
                        let proposal : ProposalItem = ProposalItem(title: self.title, abstract: self.abstract)
                        context.insert(proposal)
                        do {
                            try context.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                        dismiss()
                    }
                    .disabled(!isFormValid)
                    .buttonStyle(.bordered)
                    .listRowBackground(bgColor)
                    .foregroundStyle(self.colorScheme == .dark ? .white : .black)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(bgColor)
            .navigationTitle("Add proposal")
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(.primary)
        }
        .accentColor(.primary)
        .background(self.colorScheme == .dark ? .black : .white)
    }
}
