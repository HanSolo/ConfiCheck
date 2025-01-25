//
//  ContentView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject           private var model               : ConfiModel
    @State                       private var conferencesPerMonth : [Int : [ConferenceItem]] = [:]
    @State                       private var filteredConferences : [Int : [ConferenceItem]] = [:]
    @State                       private var isExpanded          : Set<Int>                 = []
    @State                       private var filter              : Int                      = 0
    
    private let formatter                                        : DateFormatter            = DateFormatter()
    private let calendar                                         : Calendar                 = .current
    
            
    var body: some View {
        VStack {
            Text("Java Conferences")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
            
            Picker("Filter", selection: $filter) {
                Text("All").tag(0)
                Text("Speaking").tag(1)
                Text("CfP open").tag(2)
            }
            .pickerStyle(.segmented)
            
            List {
                ForEach(self.filteredConferences.keys.sorted(), id: \.self) { month in
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
                                ForEach(self.filteredConferences[month]!.sorted(by: { $0.date < $1.date })) { conference in
                                    ConferenceView(conference: conference)
                                }
                            },
                            header: {
                                HStack {
                                    Text("\(formatter.monthSymbols[month-1].capitalized)")
                                    Text("\(self.filteredConferences[month]!.count > 0 ? "( \(self.filteredConferences[month]!.count) )" : "")")
                                        .foregroundStyle(.secondary)
                                    
                                }
                            }
                    )
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .listRowBackground(Color(.systemGray6))
                    .accentColor(Color(.systemGray2))
                }
            }
            .listStyle(.sidebar)
            //.background(Color(.systemGray2))
            //.accentColor(Color(.systemPurple))
            .scrollContentBackground(.hidden)
            .onAppear {
                self.isExpanded.insert(calendar.component(.month, from: Date.now))
            }
        }
        .onChange(of: self.filter) {
            self.filteredConferences.removeAll()
            switch filter {
            case 0:
                self.filteredConferences = self.conferencesPerMonth
                self.isExpanded.removeAll()
                self.isExpanded.insert(calendar.component(.month, from: Date.now))
                break
            case 1:
                for month in self.conferencesPerMonth.keys {
                    for conference in self.conferencesPerMonth[month] ?? [] {
                        if self.model.attendence.keys.contains(where: { $0 == conference.id }) {
                            if self.model.attendence[conference.id] != 2 { continue }
                            if !filteredConferences.keys.contains(month) {
                                filteredConferences[month] = []
                            }
                            filteredConferences[month]!.append(conference)
                        }
                    }
                }
                self.isExpanded.removeAll()
                for month in 1...12 {
                    self.isExpanded.insert(month)
                }
                break
            case 2:
                for month in self.conferencesPerMonth.keys {
                    if self.conferencesPerMonth[month]?.isEmpty ?? true { continue }
                    self.filteredConferences[month] = self.conferencesPerMonth[month]?.filter({ $0.cfpDate != nil })
                                                                                      .filter({ Helper.getDatesFromJavaConferenceDate(date: $0.cfpDate!).0 != nil })
                                                                                      .filter({ Helper.isCfpOpen(date: Helper.getDatesFromJavaConferenceDate(date: $0.cfpDate!).0!) })
                }
                self.isExpanded.removeAll()
                for month in 1...12 {
                    self.isExpanded.insert(month)
                }
                break
            default:
                self.filteredConferences = self.conferencesPerMonth
                break
            }
        }
        .task {
            self.filteredConferences.removeAll()
            let javaConferences : [JavaConference] = await RestController.fetchJavaConferences()
            for javaConference in javaConferences {
                let conference : ConferenceItem = JavaConference.convertToConferenceItem(javaConference: javaConference)
                if javaConference.date == nil { continue }
                let month : Int = calendar.component(.month, from: conference.date)
                if !self.conferencesPerMonth.keys.contains(month) {
                    self.conferencesPerMonth[month] = []
                    self.filteredConferences[month] = []
                }
                self.conferencesPerMonth[month]!.append(conference)
                self.filteredConferences[month]!.append(conference)
                self.model.conferences.append(conference)
            }            
        }
    }
}
