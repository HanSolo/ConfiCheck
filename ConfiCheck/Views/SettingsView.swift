//
//  SettingsView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 23.09.25.
//

import SwiftUI


struct SettingsView: View {
    @EnvironmentObject      private var model : ConfiModel
    @Environment(\.dismiss) private var dismiss
    @State                  private var showUpcomingOnly = Properties.instance.showUpcomingOnly!
    
    
    private let dateFormatter: DateFormatter = {
        let formatter : DateFormatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d M yyyy")
        return formatter
    }()
    
        
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.glass)
                .foregroundStyle(.primary)
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            
            HStack {
                Text("Export CSV")
                    .font(.system(size: 14, weight: .light, design: .rounded))
                Spacer()
                ShareLink(item: getCSVText()) {
                    Label("", systemImage: "square.and.arrow.up")
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 8))
                        .imageScale(.medium)
                }
                    .font(.system(size: 14, weight: .light, design: .rounded))
                    .accentColor(.primary)
                    .buttonStyle(.glass)
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            
            HStack {
                Text("Only upcoming conferences")
                    .font(.system(size: 14, weight: .light, design: .rounded))
                Spacer()
                Toggle("", isOn: self.$showUpcomingOnly)
                    .font(.system(size: 14, weight: .light, design: .rounded))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 6))
            }
            
            Divider()
                .overlay(.secondary)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            
            HStack {
                Text("Reset data")
                    .font(.system(size: 14, weight: .light, design: .rounded))
                Spacer()
                Button(action: {
                    self.model.triggerReset.toggle()
                }) {
                    Image(systemName: "arrow.trianglehead.2.counterclockwise").imageScale(.medium)
                        .foregroundColor(.primary)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                .buttonStyle(.glass)
                .font(.system(size: 14, weight: .light, design: .rounded))
            }
            
            Spacer()
        }
        .padding()
        .onChange(of: self.showUpcomingOnly) {
            self.model.showUpcomingOnly = self.showUpcomingOnly            
        }
    }
    
    
    // Get CSV text of conferences you speak at
    private func getCSVText() -> String {
        if self.model.conferencesPerMonth.isEmpty { return "" }
        var csvText : String = "\"Conference\",\"Date\",\"City\",\"Country\",\"Proposal(s)\"\n"
        for month in self.model.conferencesPerContinent.keys {
            for conference in self.model.conferencesPerContinent[month] ?? [] {
                if self.model.attendence.keys.contains(where: { $0 == conference.id }) {
                    if self.model.attendence[conference.id] != 2 { continue }
                    csvText += "\"\(conference.name)\",\"\(dateFormatter.string(from: conference.date))\",\"\(conference.city)\",\"\(conference.country)\",\""
                    if conference.proposals != nil && conference.proposals!.count > 0 {
                        conference.proposals!.forEach({ (proposal) in
                            if !proposal.title.isEmpty {
                                csvText += "\(proposal.title)|"
                            }
                        })
                    }
                    if csvText.last == "|" { csvText.removeLast() }
                    csvText += "\"\n"
                }
            }
        }
        return csvText
    }
}
