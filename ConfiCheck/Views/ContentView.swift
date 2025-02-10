//
//  ContentView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject           private var model              : ConfiModel
    @State                       private var isExpanded         : Set<Int>      = []
    @State                       private var continent          : Int           = Properties.instance.selectedContinent!
    @State                       private var filter             : Int           = 0
    @State                       private var speakerInfoVisible : Bool          = false
    @State                       private var proposalsVisible   : Bool          = false
    @State                       private var updating           : Bool          = false
    private let formatter                                       : DateFormatter = DateFormatter()
    private let calendar                                        : Calendar      = .current
    private let dateFormatter: DateFormatter = {
        let formatter : DateFormatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d M yyyy")
        return formatter
    }()
    
            
    var body: some View {
        VStack {
            Text("Conferences")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
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
                Text("Speaking").tag(1)
                Text("CfP open").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))

            Divider()
                .overlay(.secondary)
            
            if self.model.networkMonitor.isConnected {
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
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .onAppear {
                    self.isExpanded.insert(calendar.component(.month, from: Date.now))
                }
                .refreshable {
                    updateAll()
                }
            } else {
                Spacer()
                VStack(spacing: 20) {
                    Text("O F F L I N E")
                        .font(.system(size: 48, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("You need to be online\nto see the conferences")
                        .font(.system(size: 24, weight: .thin, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            Divider()
                .overlay(.secondary)
            
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
        .sheet(isPresented: $speakerInfoVisible) {
            SpeakerInfoView()
        }
        .sheet(isPresented: $proposalsVisible) {
            ProposalsView()
        }
        .task {
            updateAll()
        }
    }
    
    // Get CSV text of conferences you speak at
    private func getCSVText() -> String {
        if self.model.conferencesPerMonth.isEmpty { return "" }
        var csvText : String = ""
        for month in self.model.conferencesPerContinent.keys {
            for conference in self.model.conferencesPerContinent[month] ?? [] {
                if self.model.attendence.keys.contains(where: { $0 == conference.id }) {
                    if self.model.attendence[conference.id] != 2 { continue }
                    csvText += "\"\(conference.name)\",\"\(dateFormatter.string(from: conference.date))\",\"\(conference.city)\",\"\(conference.country)\""
                    if conference.proposals != nil && conference.proposals!.count > 0 {
                        conference.proposals!.forEach({ (proposal) in
                            if !proposal.title.isEmpty {
                                csvText += ",\"\(proposal.title)\""
                            }
                        })
                    }
                    csvText += "\n"
                }
            }
        }
        return csvText
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
                    return isoInfo?.continent == selectedContinent.code
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
            for javaConference in javaConferences {
                let conference : ConferenceItem = JavaConference.convertToConferenceItem(javaConference: javaConference)
                if javaConference.date == nil { continue }
                conferencesFound.append(conference)
            }
            for conference in conferencesFound {
                if self.model.conferences.contains(where: { $0.id == conference.id }) {
                    let conferenceItem : ConferenceItem = self.model.conferences.filter({$0.id == conference.id}).first!
                    conferenceItem.cfpDate = conference.cfpDate
                    conferenceItem.cfpUrl  = conference.cfpUrl
                } else {
                    self.model.conferences.append(conference)
                }
            }
            self.model.update.toggle()
            updateList()
            storeItemsToCloudKit(force: true)
            loadProposalItemsFromCloudKit()
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
        if !conferenceItems.isEmpty {
            if self.model.conferences.isEmpty {
                for conference in conferenceItems {
                    self.model.conferences.append(conference)                    
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
