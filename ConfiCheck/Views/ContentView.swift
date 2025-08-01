//
//  ContentView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import SwiftUI
import SwiftData
import WidgetKit
import EventKit


struct ContentView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject           private var model              : ConfiModel
    @State                       private var isExpanded         : Set<Int>       = []
    @State                       private var continent          : Int            = Properties.instance.selectedContinent!
    @State                       private var filter             : Int            = 0
    @State                       private var speakerInfoVisible : Bool           = false
    @State                       private var proposalsVisible   : Bool           = false
    @State                       private var updating           : Bool           = false
    @State                       private var searchText         : String         = ""
    @State                       private var scrollPosition     : ScrollPosition = ScrollPosition()
    private let formatter                                       : DateFormatter  = DateFormatter()
    private let calendar                                        : Calendar       = .current
    private let dateFormatter: DateFormatter = {
        let formatter : DateFormatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d M yyyy")
        return formatter
    }()
    
            
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Text("Continents")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                    Spacer()
                    Picker("Continent", selection: $continent) {
                        Text(Constants.Continent.all.name).tag(0)
                        Text(Constants.Continent.africa.name).tag(1)
                        Text(Constants.Continent.antarctica.name).tag(2)
                        Text(Constants.Continent.asia.name).tag(3)
                        Text(Constants.Continent.europe.name).tag(4)
                        Text(Constants.Continent.northAmerica.name).tag(5)
                        Text(Constants.Continent.oceania.name).tag(6)
                        Text(Constants.Continent.southAmerica.name).tag(7)
                    }
                    .pickerStyle(.menu)
                    .accentColor(.primary)
                }
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                
                Picker("Filter", selection: $filter) {
                    Text("All").tag(0)
                    Text("Speaking").backgroundStyle(Constants.GREEN).tag(1)
                    Text("Attending").tag(2)
                    Text("CfP open").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                
                Divider()
                    .overlay(.secondary)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                                
                HStack {
                    Spacer()
                    Text("OFFLINE")
                        .font(.system(size: 8))
                        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                        .foregroundStyle(.white)
                        .background(
                            ZStack {
                                RoundedRectangle(
                                    cornerRadius: 5,
                                    style       : .continuous
                                )
                                .fill(.red)
                                RoundedRectangle(
                                    cornerRadius: 5,
                                    style       : .continuous
                                )
                                .stroke(.red, lineWidth: 1)
                            }
                        )
                        .opacity(self.model.networkMonitor.isConnected ? 0.0 : 1.0)
                    Spacer()
                }
                NavigationStack {
                    List {
                        ForEach(self.model.filteredConferences.keys.sorted(), id: \.self) { month in
                            Section(isExpanded: Binding<Bool> (
                                get: {
                                    return isExpanded.contains(month)
                                },
                                set: { isExpanding in
                                    if isExpanding {
                                        isExpanded.insert(month)
                                    } else {
                                        isExpanded.remove(month)
                                    }
                                }
                            ),
                            content: {
                                ForEach(self.model.filteredConferences[month]!.sorted(by: { $0.date < $1.date })) { conference in
                                    ConferenceView(conference: conference)
                                        .alignmentGuide(.listRowSeparatorLeading) { d in
                                            d[.leading]
                                        }
                                        .alignmentGuide(.listRowSeparatorTrailing) { d in
                                            d[.trailing]
                                        }
                                }
                            },
                            header: {
                                HStack {
                                    Text("\(formatter.monthSymbols[month-1].capitalized)")
                                    Text("\(self.model.filteredConferences[month]!.count > 0 ? "( \(self.model.filteredConferences[month]!.count) )" : "")")
                                        .foregroundStyle(.secondary)
                                    
                                }
                            }
                            )
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .listRowBackground(Color(.systemGray6))
                            .listRowSeparator(.automatic)
                            .listRowSeparatorTint(.secondary)
                            .listRowSpacing(0)
                            .accentColor(Color(.systemGray2))
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        self.isExpanded.insert(calendar.component(.month, from: Date.now))
                    }
                    .refreshable {
                        updateAll()
                    }
                    .listStyle(.sidebar)
                    .navigationTitle("Conferences")
                    .searchable(text: $searchText, placement: .automatic, prompt: "Search for conference...")
                    .textInputAutocapitalization(.never)
                    .toolbarTitleDisplayMode(.inline)
                }
                
                Divider()
                    .overlay(.secondary)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                TimelineView(.animation(minimumInterval: Constants.CANVAS_REFRESH_INTERVAL)) { timeline in
                    ScrollView(.horizontal) {
                        CalendarView()
                            .frame(width: geometry.size.width / 4.0 * 16.0, height: geometry.size.height * 0.125)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .defaultScrollAnchor(UnitPoint(x: 0.25, y: 0))
                    .scrollPosition(self.$scrollPosition, anchor: .init(x: 0.25, y: 0))
                    .onTapGesture(count: 2) {
                        self.scrollPosition.scrollTo(x: geometry.size.width / 1.5)
                    }
                }
                .padding(0)
                
                Divider()
                    .overlay(.secondary)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
                
                HStack {
                    Button("Speaker Info") {
                        self.speakerInfoVisible.toggle()
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                    .font(.system(size: 14, weight: .light, design: .rounded))
                    
                    Spacer()
                    
                    ShareLink("Export", item: getCSVText())
                        .font(.system(size: 14, weight: .light, design: .rounded))
                        .accentColor(.primary)
                    
                    Spacer()
                    
                    Button("Proposals") {
                        self.proposalsVisible.toggle()
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                    .font(.system(size: 14, weight: .light, design: .rounded))
                }
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            }
            .onChange(of: self.continent) {
                Properties.instance.selectedContinent = self.continent
                let selectedContinent : Constants.Continent = Constants.Continent.allCases[self.continent]
                self.model.conferencesPerContinent.removeAll();
                if self.continent == 0 {
                    self.model.conferencesPerContinent = self.model.conferencesPerMonth
                } else {
                    for month in self.model.conferencesPerMonth.keys {
                        if self.model.conferencesPerMonth[month]?.isEmpty ?? true { continue }
                        self.model.conferencesPerContinent[month] = self.model.conferencesPerMonth[month]?.filter({
                            let isoInfo : IsoCountryInfo? = IsoCountryCodes.searchByName($0.country)
                            return isoInfo?.continent == selectedContinent.code
                        })
                    }
                }
                self.isExpanded.removeAll()
                self.isExpanded.insert(calendar.component(.month, from: Date.now))
                updateList()
            }
            .onChange(of: self.filter) {
                self.model.filteredConferences.removeAll()
                switch self.filter {
                case 0:
                    self.model.filteredConferences = self.model.conferencesPerContinent
                    self.isExpanded.removeAll()
                    self.isExpanded.insert(calendar.component(.month, from: Date.now))
                    break
                case 1:
                    for month in self.model.conferencesPerContinent.keys {
                        for conference in self.model.conferencesPerContinent[month] ?? [] {
                            if self.model.attendence.keys.contains(where: { $0 == conference.id }) {
                                if self.model.attendence[conference.id] != 2 { continue }
                                if !self.model.filteredConferences.keys.contains(month) {
                                    self.model.filteredConferences[month] = []
                                }
                                self.model.filteredConferences[month]!.append(conference)
                            }
                        }
                    }
                    self.isExpanded.removeAll()
                    for month in 1...12 {
                        self.isExpanded.insert(month)
                    }
                    break
                case 2:
                    for month in self.model.conferencesPerContinent.keys {
                        for conference in self.model.conferencesPerContinent[month] ?? [] {
                            if self.model.attendence.keys.contains(where: { $0 == conference.id }) {
                                if self.model.attendence[conference.id] != 1 { continue }
                                if !self.model.filteredConferences.keys.contains(month) {
                                    self.model.filteredConferences[month] = []
                                }
                                self.model.filteredConferences[month]!.append(conference)
                            }
                        }
                    }
                    self.isExpanded.removeAll()
                    for month in 1...12 {
                        self.isExpanded.insert(month)
                    }
                    break
                case 3:
                    for month in self.model.conferencesPerContinent.keys {
                        if self.model.conferencesPerContinent[month]?.isEmpty ?? true { continue }
                        self.model.filteredConferences[month] = self.model.conferencesPerContinent[month]?.filter({ $0.cfpDate != nil })
                            .filter({ Helper.getDatesFromJavaConferenceDate(date: $0.cfpDate!).0 != nil })
                            .filter({ Helper.isCfpOpen(date: Helper.getDatesFromJavaConferenceDate(date: $0.cfpDate!).0!) })
                    }
                    self.isExpanded.removeAll()
                    for month in 1...12 {
                        self.isExpanded.insert(month)
                    }
                    break
                default:
                    self.model.filteredConferences = self.model.conferencesPerContinent
                    break
                }
            }
            .onChange(of: self.searchText) {
                if searchText.isEmpty {
                    updateList()
                } else {
                    search()
                }
            }
            .sheet(isPresented: $speakerInfoVisible) {
                SpeakerInfoView()
            }
            .sheet(isPresented: $proposalsVisible) {
                ProposalsView()
            }
            .task {
                updateAll()
                await Cache.shared.updateJavaChampions()
            }
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
    
    // Filter list by search
    private func search() {
        guard !searchText.isEmpty else { return }
        self.model.filteredConferences.removeAll()
        for month in self.model.conferencesPerContinent.keys {
            if self.model.conferencesPerContinent[month]?.isEmpty ?? true { continue }
            self.model.filteredConferences[month] = self.model.conferencesPerContinent[month]?.filter({ $0.name.localizedCaseInsensitiveContains(self.searchText) })
        }
        self.model.filteredConferences.keys.sorted().forEach({ month in
            self.isExpanded.insert(month)
        })
    }
    
    // Update list
    private func updateList() -> Void {
        let selectedContinent : Constants.Continent = Constants.Continent.allCases[self.continent]
        self.model.conferencesPerContinent.removeAll();
        if self.continent == 0 {
            self.model.conferencesPerContinent = self.model.conferencesPerMonth
        } else {
            for month in self.model.conferencesPerMonth.keys {
                if self.model.conferencesPerMonth[month]?.isEmpty ?? true { continue }
                self.model.conferencesPerContinent[month] = self.model.conferencesPerMonth[month]?.filter({
                    let isoInfo : IsoCountryInfo? = IsoCountryCodes.searchByName($0.country)
                    return isoInfo?.continent == selectedContinent.code || isoInfo == nil
                })
            }
        }
        
        self.model.filteredConferences.removeAll()
        switch self.filter {
            case 0:
                self.model.filteredConferences = self.model.conferencesPerContinent
                self.isExpanded.removeAll()
                self.isExpanded.insert(calendar.component(.month, from: Date.now))
                break
            case 1:
                for month in self.model.conferencesPerContinent.keys {
                    for conference in self.model.conferencesPerContinent[month] ?? [] {
                        if self.model.attendence.keys.contains(where: { $0 == conference.id }) {
                            if self.model.attendence[conference.id] != 2 { continue }
                            if !self.model.filteredConferences.keys.contains(month) {
                                self.model.filteredConferences[month] = []
                            }
                            self.model.filteredConferences[month]!.append(conference)
                        }
                    }
                }
                self.isExpanded.removeAll()
                for month in 1...12 {
                    self.isExpanded.insert(month)
                }
                break
            case 2:
                for month in self.model.conferencesPerContinent.keys {
                    for conference in self.model.conferencesPerContinent[month] ?? [] {
                        if self.model.attendence.keys.contains(where: { $0 == conference.id }) {
                            if self.model.attendence[conference.id] != 1 { continue }
                            if !self.model.filteredConferences.keys.contains(month) {
                                self.model.filteredConferences[month] = []
                            }
                            self.model.filteredConferences[month]!.append(conference)
                        }
                    }
                }
                self.isExpanded.removeAll()
                for month in 1...12 {
                    self.isExpanded.insert(month)
                }
            break
            case 3:
                for month in self.model.conferencesPerContinent.keys {
                    if self.model.conferencesPerContinent[month]?.isEmpty ?? true { continue }
                    self.model.filteredConferences[month] = self.model.conferencesPerContinent[month]?.filter({ $0.cfpDate != nil })
                                                                                                      .filter({ Helper.getDatesFromJavaConferenceDate(date: $0.cfpDate!).0 != nil })
                                                                                                      .filter({ Helper.isCfpOpen(date: Helper.getDatesFromJavaConferenceDate(date: $0.cfpDate!).0!) })
                }
                self.isExpanded.removeAll()
                for month in 1...12 {
                    self.isExpanded.insert(month)
                }
                break
            default:
                self.model.filteredConferences = self.model.conferencesPerContinent
                break
        }
    }
    
    // Update all data
    @MainActor
    private func updateAll() -> Void {
        Task {
            loadItemsFromCloudKit()
            
            let javaConferences  : [JavaConference] = await RestController.fetchJavaConferences()
            var conferencesFound : [ConferenceItem] = []
            let now  : Date = Date.now
            let year : Int  = now.getYear()
            for javaConference in javaConferences {
                let conference : ConferenceItem = JavaConference.convertToConferenceItem(javaConference: javaConference)
                if javaConference.date == nil { continue }
                if year == conference.date.getYear() {
                    conferencesFound.append(conference)
                } else if year < conference.date.getYear() && conference.date.getMonth() < 7 {
                    conferencesFound.append(conference)
                }
            }
            for conference in conferencesFound {
                if self.model.conferences.contains(where: { $0.id == conference.id }) {
                    let conferenceItem : ConferenceItem = self.model.conferences.filter({$0.id == conference.id}).first!
                    conferenceItem.cfpDate = conference.cfpDate
                    conferenceItem.cfpUrl  = conference.cfpUrl
                    conferenceItem.days    = conference.days
                } else {
                    self.model.conferences.append(conference)
                }
            }
            self.model.update.toggle()
            updateList()
            storeItemsToCloudKit(force: true)
            loadProposalItemsFromCloudKit()
            
            Helper.storeConferencesThisMonthToUserDefaults(conferencesPerMonth: self.model.conferencesPerMonth, attendence: self.model.attendence)
            Helper.storeConferencesWithOpenCfPToUserDefaults(conferences: self.model.conferencesWithOpenCfp)
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // CloudKit related functions
    private func storeItemsToCloudKit(force: Bool) -> Void {
        // Upload Items to CloudKit if not already happened today
        do {
           let lastItemsSaved : Date = Date(timeIntervalSince1970: Properties.instance.lastItemsSaved!)
            if force {
                if self.model.conferences.count > 0 {
                    for conference in self.model.conferences {
                        context.insert(conference)
                    }
                    try context.save()
                    Properties.instance.lastItemsSaved = Date.now.timeIntervalSince1970
                    debugPrint("Conferences saved to CloudKit")
                } else {
                    debugPrint("No conferences loaded -> not saved")
                }
            } else if calendar.component(.day, from: lastItemsSaved) != calendar.component(.day, from: Date.now) {
                if self.model.conferences.count > 0 {
                    for conference in self.model.conferences {
                        context.insert(conference)
                    }
                    try context.save()
                    Properties.instance.lastItemsSaved = Date.now.timeIntervalSince1970
                    debugPrint("Conferences saved to CloudKit")
                } else {
                    debugPrint("No conferences loaded -> not saved")
                }
            } else {
                debugPrint("Items have been already saved to CloudKit today")
            }
        } catch {
            debugPrint(error)
        }
    }
    private func loadItemsFromCloudKit() -> Void {
        // Conference Items
        self.model.conferences.removeAll()
        let requestConferences = FetchDescriptor<ConferenceItem>()
        let conferenceItems : [ConferenceItem] = try! context.fetch(requestConferences)
        let now  : Date = Date.now
        let year : Int  = now.getYear()
        if !conferenceItems.isEmpty {
            if self.model.conferences.isEmpty {
                for conference in conferenceItems {
                    if year == conference.date.getYear() {
                        self.model.conferences.append(conference)
                    } else if year < conference.date.getYear() && conference.date.getMonth() < 7 {
                        self.model.conferences.append(conference)
                    }
                }
            }
        }
        debugPrint("\(conferenceItems.count) conference items loaded from CloudKit")
        self.model.conferences = self.model.conferences.uniqueElements()
        self.model.update.toggle()
                                        
        /* Remove duplicates if needed
        if conferenceItems.count != self.model.conferences.count {
            removeDuplicatesFromCloudKit()
        }
        */
    }
    private func removeDuplicatesFromCloudKit() -> Void {
        resetAllItems()
        let cleanedUpConferenceItems : [ConferenceItem] = self.model.conferences.uniqueElements()
        
        do {
            for conferenceItem in cleanedUpConferenceItems {
                context.insert(conferenceItem)
            }
            
            try context.save()
            debugPrint("Removed duplicates from CloudKit")
        } catch {
            debugPrint("Error removing duplicates from CloudKit. \(error)")
        }
    }
    private func resetAllItems() -> Void {
        do {
            try context.delete(model: ConferenceItem.self)
            debugPrint("Reset all items")
        } catch {
            debugPrint("Error resetting all items. \(error)")
        }
    }
    
    private func loadProposalItemsFromCloudKit() -> Void {
        // Proposal Items
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
    }
}
