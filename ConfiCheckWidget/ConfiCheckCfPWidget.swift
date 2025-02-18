//
//  ConfiCheckCfPWidget.swift
//  ConfiCheckWidgetExtension
//
//  Created by Gerrit Grunwald on 18.02.25.
//

import WidgetKit
import SwiftUI

struct CfPProvider: TimelineProvider {
    @EnvironmentObject private var model : ConfiModel
    
    func placeholder(in context: Context) -> ConfiCheckEntry {
        let conferences : [Conference] = Helper.readConferencesWithOpenCfPFromUserDefaults()
        return ConfiCheckEntry(date: Date(), conferences: conferences)
    }

    func getSnapshot(in context: Context, completion: @escaping (ConfiCheckEntry) -> ()) {
        let conferences : [Conference]    = Helper.readConferencesWithOpenCfPFromUserDefaults()
        let entry       : ConfiCheckEntry = ConfiCheckEntry(date: Date(), conferences: conferences)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries : [ConfiCheckEntry] = []
        let now     : Date              = Date()

        for hourOffset in 0 ..< 2 { // 2 entries an hour
            let entryDate   : Date            = Calendar.current.date(byAdding: .hour, value: hourOffset, to: now)!
            let conferences : [Conference]    = Helper.readConferencesWithOpenCfPFromUserDefaults()
            let entry       : ConfiCheckEntry = ConfiCheckEntry(date: entryDate, conferences: conferences)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}


struct ConfiCheckCfPEntry: TimelineEntry {
    let date        : Date
    let conferences : [Conference]
}


struct ConfiCheckCfPWidgetEntryView : View {
    @Environment(\.widgetFamily) private var family
        
    private let dateFormatter : DateFormatter = {
        let formatter : DateFormatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d M")
        return formatter
    }()
    private var entry         : CfPProvider.Entry
    
    
    init(entry: CfPProvider.Entry) {
        self.entry = entry
    }

    
    var body: some View {
        let sorted : [Conference] = Array(self.entry.conferences).sorted(by: { lhs, rhs in
            return rhs.cfp > lhs.cfp
        })        
        
        if family == .systemLarge {
            VStack {
                if self.entry.conferences.isEmpty {
                    Text("No conferences with open CfP")
                        .font(.system(size: 13))
                } else {
                    Text("Conferences with open CfP")
                        .font(.system(size: 13))
                    ForEach(Array(sorted)) { conference in
                        HStack {
                            let isoInfo : IsoCountryInfo? = IsoCountryCodes.searchByName(conference.country)
                            let flag    : String          = isoInfo?.flag ?? ""
                            // Country Flag
                            if isoInfo == nil {
                                Image(systemName: "network")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.primary)
                            } else {
                                Text(flag)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.primary)
                                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                            }
                            Spacer()
                            Text(conference.name)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                            Text(dateFormatter.string(from: conference.cfp) )
                                .font(.system(size: 12, weight: .medium, design: .rounded))
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

struct ConfiCheckCfPWidget: Widget {
    @Environment(\.widgetFamily) private var family
    
    let kind: String = "ConfiCheckCfPWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CfPProvider()) { entry in
            if #available(iOS 17.0, *) {
                ConfiCheckCfPWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ConfiCheckCfPWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("ConfiCheck CfP Widget")
        .description("Conferences with open CfP")
        .supportedFamilies([.systemLarge])
    }
}
