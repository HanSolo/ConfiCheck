//
//  ConferenceView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 22.01.25.
//

import SwiftUI
import CoreLocation

struct ConferenceView: View {
    @EnvironmentObject private var model                   : ConfiModel
    @State             private var conference              : ConferenceItem
    @State             private var selectedAttendenceIndex : Int = 0

    let formatter : DateFormatter
    
    
    init(conference: ConferenceItem) {
        self.conference = conference        
        formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd MMMM")
    }
    
    
    var body: some View {
        let isoInfo : IsoCountryInfo? = IsoCountryCodes.searchByName(conference.country)
        let flag    : String          = isoInfo?.flag ?? ""
        
        VStack(spacing: 10) {
            HStack {
                // Conference Name
                Text(conference.name)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // Country Flag
                if isoInfo == nil {
                    Image(systemName: "network")
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                } else {
                    Text(flag)
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)
                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                }
            }
            
            HStack {
                // Conference Date
                Text(verbatim: "\(self.formatter.string(from: conference.date))")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // City Name
                Text(verbatim: "\(conference.city)\( (isoInfo != nil ? isoInfo!.name : conference.country).isEmpty ? "" : ",")")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                
                // Country Name
                Text(verbatim: "\(isoInfo != nil ? isoInfo!.name : conference.country)")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                if conference.url.isEmpty {
                    Spacer()
                } else {
                    // Link to Website
                    HStack {
                        Text("WEB")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.primary)
                        Link(destination: URL(string: conference.url)!) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.primary)
                                .rotationEffect(.degrees(90))
                        }
                    }
                    .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))
                    .background(
                        ZStack {
                            RoundedRectangle(
                                cornerRadius: 5,
                                style       : .continuous
                            )
                            .fill(.tertiary)
                            RoundedRectangle(
                                cornerRadius: 5,
                                style       : .continuous
                            )
                            .stroke(.tertiary)
                        }
                    )
                }
                
                Spacer()
                
                // Open in Maps
                Button {
                    
                } label: {
                    HStack {
                        Text("Map")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.primary)
                        Image(systemName: "location")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(self.conference.lat == nil || self.conference.lon == nil || (self.conference.lat == 0.0 && self.conference.lon == 0.0) ? .secondary : .primary)
                    }
                }
                .highPriorityGesture(TapGesture().onEnded {
                    if self.conference.lat == nil || self.conference.lon == nil || (self.conference.lat == 0.0 && self.conference.lon == 0.0) { return }
                    let urlApple : URL = URL(string: "http://maps.apple.com/?q=\(self.conference.lat ?? 0.0),\(self.conference.lon ?? 0.0)")!
                    if UIApplication.shared.canOpenURL(urlApple) {
                        UIApplication.shared.open(urlApple, options: [:], completionHandler: nil)
                    }
                })
                .disabled(self.conference.lat == nil || self.conference.lon == nil || (self.conference.lat == 0.0 && self.conference.lon == 0.0))
                .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))
                .background(
                    ZStack {
                        RoundedRectangle(
                            cornerRadius: 5,
                            style       : .continuous
                        )
                        .fill(.tertiary)
                        RoundedRectangle(
                            cornerRadius: 5,
                            style       : .continuous
                        )
                        .stroke(.tertiary)
                    }
                )
            }
            
            // CfP and Attendence
            HStack {
                if self.conference.cfpUrl != nil && !self.conference.cfpUrl!.isEmpty {
                    CfpView(endDate: Helper.getDatesFromJavaConferenceDate(date: self.conference.cfpDate ?? "").0, link: self.conference.cfpUrl)
                }
                
                Spacer()
                
                Menu {
                    Picker(selection: $selectedAttendenceIndex) {
                        Text("\(Constants.AttendingStatus.notAttending.uiString)").tag(0)
                        Text("\(Constants.AttendingStatus.attending.uiString)").tag(1)
                        Text("\(Constants.AttendingStatus.speaking.uiString)").tag(2)
                    } label: {}
                } label: {                    
                    Text("\(Constants.AttendingStatus.getUiStrings()[self.selectedAttendenceIndex])")
                        .font(.system(size: 14, weight: .light, design: .rounded))
                        .foregroundStyle(self.selectedAttendenceIndex == 2 ? Constants.GREEN : .secondary)
                }
            }
            
            /* Proposals
            if self.model.proposals.count > 0 {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Proposals")
                            .font(.system(size: 14, weight: .light, design: .rounded))
                        
                        Spacer()
                        
                        Button {
                            //self.addProposalViewVisible = true
                        } label: {
                            Label("", systemImage: "plus.circle")
                                .padding()
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14, weight: .light, design: .rounded))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.primary)
                    }
                }
            }
            */
        }
        .task {
            if self.model.attendence.keys.contains(where: { $0 == self.conference.id }) {                
                let index : Int = self.model.attendence[self.conference.id] ?? 0
                self.selectedAttendenceIndex = index
            }
        }
        .onChange(of: self.selectedAttendenceIndex) {
            self.model.attendence[self.conference.id] = self.selectedAttendenceIndex
        }
    }
}

