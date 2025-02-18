//
//  ConferenceView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 22.01.25.
//

import SwiftUI
import CoreLocation
import EventKit

struct ConferenceView: View, Identifiable {
    @Environment(\.openURL)                 private var openURL
    @Environment(\.defaultMinListRowHeight) private var minRowHeight
    @Environment(\.modelContext)            private var context
    @EnvironmentObject                      private var model                    : ConfiModel
    @State                                  private var conference               : ConferenceItem
    @State                                  private var selectedAttendenceIndex  : Int    = 0
    @State                                  private var proposalSelectionVisible : Bool   = false
    @State                                  private var showAlert                : Bool   = false
    @State                                  private var alertTitle               : String = ""
    @State                                  private var alertMessage             : String = ""

    let calendar  : Calendar = Calendar.current
    var id        : String   = UUID().uuidString
    let formatter : DateFormatter
    
    
    init(conference: ConferenceItem) {
        self.conference = conference        
        formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd MMMM")
    }
    
    
    var body: some View {
        let isoInfo : IsoCountryInfo? = IsoCountryCodes.searchByName(conference.country)
        let flag    : String          = isoInfo?.flag ?? ""
        
        VStack(spacing: 12) {
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
                if conference.days > 1 {
                    Text(verbatim: "\(self.formatter.string(from: conference.date)) (\(String(format: "%.0f", conference.days)) days)")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.primary)
                } else {
                    Text(verbatim: "\(self.formatter.string(from: conference.date))")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.primary)
                }
                
                // Add to calendar
                Button() {
                    addConferenceToCalendar(self.conference)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.primary)
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
                        
                        Button() {
                            //guard let url = URL(string: conference.url) else { return }
                            //openURL(url)
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.primary)
                                .rotationEffect(.degrees(90))
                                .onTapGesture {
                                    guard let url = URL(string: conference.url) else { return }
                                    openURL(url)
                                }
                        }
                        .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))                        
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
                    CfpView(endDate: Helper.getDatesFromJavaConferenceDate(date: self.conference.cfpDate ?? "").0?.endOfDay(), link: self.conference.cfpUrl)
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
                        .font(.system(size: 14, weight: self.selectedAttendenceIndex == 2 ? .medium : .light, design: .rounded))
                        .foregroundStyle(Constants.AttendingStatus.allCases[self.selectedAttendenceIndex].color)
                }
            }
            
            // Proposals
            if self.model.proposals.count > 0 {
                HStack {
                    Text("Proposals")
                        .font(.system(size: 14, weight: .light, design: .rounded))
                    
                    Spacer()
                                                            
                    Button {
                        self.model.selectedConference = self.conference
                        self.proposalSelectionVisible.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16, weight: .light, design: .rounded))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                    .popover(isPresented: $proposalSelectionVisible) {
                        ProposalSelectionView(proposals: self.model.proposals)
                    }
                }
                
                if self.conference.proposals != nil && self.conference.proposals!.count > 0 {                    
                    List{
                        ForEach(self.conference.proposals!, id: \.self) { proposal in
                            ProposedView(proposal: proposal, conference: self.conference)
                                .alignmentGuide(.listRowSeparatorLeading) { d in
                                    d[.leading]
                                }
                                .alignmentGuide(.listRowSeparatorTrailing) { d in
                                    d[.trailing]
                                }
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listRowSpacing(0)
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteProposalFromConference)
                    }
                    .frame(minHeight: minRowHeight * CGFloat(self.conference.proposals!.count))
                    .scrollContentBackground(.hidden)
                    .listRowSpacing(0)
                    .listStyle(.plain)
                }
            }
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
        .onChange(of: self.model.selectedProposal) {
            if self.model.selectedProposal != nil {
                if self.conference == self.model.selectedConference {
                    self.conference.proposals?.append(self.model.selectedProposal!)
                    self.model.selectedProposal   = nil
                    self.model.selectedConference = nil
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(self.alertTitle), message: Text(self.alertMessage))
        }
    }
    
    func deleteProposalFromConference(at offsets: IndexSet) {        
        self.conference.removeProposal(proposal: self.conference.proposals![offsets.first!])
    }
    
    // Request Calendar access
    private func addConferenceToCalendar(_ conference: ConferenceItem) {
        let eventStore = EKEventStore()
        eventStore.requestFullAccessToEvents { (granted, error) in
            if granted && error == nil {
                var notes : String = ""
                if !(conference.proposals?.isEmpty ?? false) {
                    notes += "Sessions:"
                    for entry in conference.proposalStates! {
                        if entry.value == Constants.ProposalStatus.accepted.apiString {
                            notes += "\n\(entry.key)"
                        }
                    }
                }
                
                let startDate           : Date       = calendar.startOfDay(for: conference.date)
                let endDate             : Date       = conference.date.addingTimeInterval((conference.days - 1) * 86400).endOfDay()
                let calendarEvent       : EKEvent    = EKEvent(eventStore: eventStore)
                calendarEvent.title     = conference.name
                calendarEvent.startDate = startDate
                calendarEvent.endDate   = endDate
                calendarEvent.notes     = notes
                calendarEvent.isAllDay  = true
                calendarEvent.location  = (conference.lat == nil || conference.lon == nil || (conference.lat == 0.0 && conference.lon == 0.0)) ? "" : "\(conference.city), \(conference.country)"
                calendarEvent.calendar  = eventStore.defaultCalendarForNewEvents
                
                let predicate          = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
                let existingEvents     = eventStore.events(matching: predicate)
                let eventAlreadyExists = existingEvents.first(where: { $0.title == conference.name && $0.startDate == startDate && $0.endDate == endDate} ) != nil
                if eventAlreadyExists {
                    alertTitle   = "Conference exists"
                    alertMessage = "\(conference.name) already exists in your calendar."
                    showAlert    = true
                } else {
                    do {
                        try eventStore.save(calendarEvent, span: .thisEvent)
                        alertTitle   = "Conference Added"
                        alertMessage = "\(conference.name) has been successfully added to your calendar."
                        showAlert    = true
                    } catch {
                        alertTitle   = "Error"
                        alertMessage = "There was an error adding the conference to your calendar."
                        showAlert    = true
                    }
                }
            } else {
                alertTitle   = "Error"
                alertMessage = "Access to the calendar was denied."
                showAlert    = true
            }
        }
    }
    
}

