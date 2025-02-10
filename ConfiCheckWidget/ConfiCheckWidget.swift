//
//  ConfiCheckWidget.swift
//  ConfiCheckWidget
//
//  Created by Gerrit Grunwald on 10.02.25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {    
    @EnvironmentObject private var model : ConfiModel
    
    func placeholder(in context: Context) -> ConfiCheckEntry {
        let conferences : [Conference] = Helper.readConferencesThisMonthFromUserDefaults()
        return ConfiCheckEntry(date: Date(), conferences: conferences)
    }

    func getSnapshot(in context: Context, completion: @escaping (ConfiCheckEntry) -> ()) {
        let conferences : [Conference]    = Helper.readConferencesThisMonthFromUserDefaults()
        let entry       : ConfiCheckEntry = ConfiCheckEntry(date: Date(), conferences: conferences)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries : [ConfiCheckEntry] = []
        let now     : Date              = Date()

        for hourOffset in 0 ..< 2 { // 2 entries an hour
            let entryDate   : Date            = Calendar.current.date(byAdding: .hour, value: hourOffset, to: now)!
            let conferences : [Conference]    = Helper.readConferencesThisMonthFromUserDefaults()
            let entry       : ConfiCheckEntry = ConfiCheckEntry(date: entryDate, conferences: conferences)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}


struct ConfiCheckEntry: TimelineEntry {
    let date        : Date
    let conferences : [Conference]
}


struct ConfiCheckWidgetEntryView : View {
    @Environment(\.widgetFamily) private var family
        
    private let dateFormatter : DateFormatter = {
        let formatter : DateFormatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d M")
        return formatter
    }()
    private var entry         : Provider.Entry
    
    
    init(entry: Provider.Entry) {
        self.entry = entry
    }

    
    var body: some View {
        let sorted : [Conference] = Array(self.entry.conferences).sorted(by: { lhs, rhs in
            return rhs.date < lhs.date
        })
        let count  : Int          = sorted.count
        
        if family == .systemLarge {
            VStack {
                if self.entry.conferences.isEmpty {
                    Text("No conferences this month")
                        .font(.system(size: 13))
                } else {
                    ForEach(Array(sorted)) { conference in
                        HStack {
                            let isoInfo : IsoCountryInfo? = IsoCountryCodes.searchByName(conference.country)
                            let flag    : String          = isoInfo?.flag ?? ""
                            // Country Flag
                            if isoInfo == nil {
                                Image(systemName: "network")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.primary)
                            } else {
                                Text(flag)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.primary)
                                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                            }
                            Spacer()
                            Text(conference.name)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                            Text(dateFormatter.string(from: conference.date) )
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                    }
                    Spacer()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .containerBackground(for: .widget) {
                Color.init(red: 0.1, green: 0.1, blue: 0.1)
            }
            .cornerRadius(5)
            .edgesIgnoringSafeArea(.all)
        } else if family == .systemMedium {
            if self.entry.conferences.isEmpty {
                VStack {
                    Text("No conferences this month")
                        .font(.system(size: 13))
                }
            } else {
                if count > 4 {
                    let left : [Conference] = Array(sorted.prefix(through: 3))
                    let right: [Conference] = Array(sorted.suffix(from: 4))
                    HStack(alignment: .top, spacing: 20) {
                        VStack {
                            ForEach(Array(left)) { conference in
                                HStack {
                                    let isoInfo : IsoCountryInfo? = IsoCountryCodes.searchByName(conference.country)
                                    let flag    : String          = isoInfo?.flag ?? ""
                                    // Country Flag
                                    if isoInfo == nil {
                                        Image(systemName: "network")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.primary)
                                    } else {
                                        Text(flag)
                                            .font(.system(size: 13))
                                            .foregroundStyle(.primary)
                                            .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                                    }
                                    Spacer()
                                    Text(conference.name)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Text(dateFormatter.string(from: conference.date) )
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.primary)
                                }
                                Spacer()
                            }
                        }
                        VStack {
                            ForEach(Array(right)) { conference in
                                HStack {
                                    let isoInfo : IsoCountryInfo? = IsoCountryCodes.searchByName(conference.country)
                                    let flag    : String          = isoInfo?.flag ?? ""
                                    // Country Flag
                                    if isoInfo == nil {
                                        Image(systemName: "network")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.primary)
                                    } else {
                                        Text(flag)
                                            .font(.system(size: 13))
                                            .foregroundStyle(.primary)
                                            .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                                    }
                                    Spacer()
                                    Text(conference.name)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Text(dateFormatter.string(from: conference.date) )
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.primary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .containerBackground(for: .widget) {
                        Color.init(red: 0.1, green: 0.1, blue: 0.1)
                    }
                    .cornerRadius(5)
                    .edgesIgnoringSafeArea(.all)
                } else {
                    VStack {
                        if self.entry.conferences.isEmpty {
                            Text("No conferences this month")
                                .font(.system(size: 13))
                        } else {
                            ForEach(Array(sorted)) { conference in
                                HStack {
                                    let isoInfo : IsoCountryInfo? = IsoCountryCodes.searchByName(conference.country)
                                    let flag    : String          = isoInfo?.flag ?? ""
                                    // Country Flag
                                    if isoInfo == nil {
                                        Image(systemName: "network")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.primary)
                                    } else {
                                        Text(flag)
                                            .font(.system(size: 13))
                                            .foregroundStyle(.primary)
                                            .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                                    }
                                    Spacer()
                                    Text(conference.name)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Text(dateFormatter.string(from: conference.date) )
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.primary)
                                }
                            }
                            Spacer()
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .containerBackground(for: .widget) {
                        Color.init(red: 0.1, green: 0.1, blue: 0.1)
                    }
                    .cornerRadius(5)
                    .edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
}

struct ConfiCheckWidget: Widget {
    @Environment(\.widgetFamily) private var family
    
    let kind: String = "ConfiCheckWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ConfiCheckWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ConfiCheckWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("ConfiCheck Widget")
        .description("Conferences you speak at this month")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
