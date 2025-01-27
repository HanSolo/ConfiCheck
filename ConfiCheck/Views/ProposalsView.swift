//
//  ProposalsView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 27.01.25.
//

import SwiftUI

struct ProposalsView: View {
    @Environment(\.dismiss)      private var dismiss
    //@Environment(\.modelContext) private var context
    @Environment(\.colorScheme)  private var colorScheme
    @EnvironmentObject           private var model : ConfiModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .padding()
                .buttonStyle(.bordered)
                .foregroundStyle(.primary)
            }
            
            Text("Proposals")
        }
    }
}
