//
//  ConfiCheckApp.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 15.01.25.
//

import SwiftUI
import SwiftData
import WidgetKit
import BackgroundTasks


@main
struct ConfiCheckApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase)                      private var phase
    
    let model    : ConfiModel       = ConfiModel()
    
    /*
     var container: ModelContainer? = {
     do {
     let configuration : ModelConfiguration = ModelConfiguration("iCloud.eu.hansolo.ConfiCheckContainer")
     let schema        : Schema             = Schema([ConferenceItem.self, ProposalItem.self, ConferenceProposalItem.self])
     let container     : ModelContainer     = try ModelContainer(for: schema, configurations: [configuration])
     return container
     } catch {
     print("Error creating ConfiCheck container: \(error)")
     return nil
     }
     }()
     */
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
            //.modelContainer(container!)
        }.onChange(of: phase) {
            //debugPrint("Scene phase changed to \(phase)")
            switch phase {
            case .active     : break
            case .inactive   : break
            case .background : scheduleAppRefresh()
            default          : break
            }
        }
        .backgroundTask(.appRefresh(Constants.APP_REFRESH_ID)) {
            debugPrint("App refresh started in background")
            
            let javaConferences : [JavaConference] = await fetchConferences(taskId: Constants.APP_REFRESH_ID)
            if Task.isCancelled {
                //debugPrint("Task was cancelled")
            } else {
                if (javaConferences.count > 0) {
                    
                    //WidgetCenter.shared.reloadTimelines(ofKind: Constants.WIDGET_KIND)
                    WidgetCenter.shared.reloadAllTimelines()
                    
                    await MainActor.run {
                        self.model.conferences.removeAll()
                        for javaConference in javaConferences {
                            //self.model.conferences.append(conference)
                        }                        
                        debugPrint("App refresh in background successful")
                    }
                } else {
                    //debugPrint("App refresh in background failed, empty entries")
                }
            }
            await scheduleAppRefresh()
        }
    }
    
    
    func scheduleAppRefresh() -> Void{
        let now     = Date.now
        let request = BGAppRefreshTaskRequest(identifier: Constants.APP_REFRESH_ID)
        request.earliestBeginDate = now.addingTimeInterval(Constants.APP_REFRESH_INTERVAL)
        try? BGTaskScheduler.shared.submit(request)
        debugPrint("Scheduled App refresh")
        // Set breakpoint here and then, after stop, paste line below in debugger and continue the exectuion
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"eu.hansolo.Sugr.refresh"]
    }
    
    func fetchConferences(taskId: String) async -> [JavaConference] {
        return []
    }
    
    /*
    func fetchLast2Entries(taskId: String) async -> [GlucoEntry] {
        let url : String = Constants.JAVA_CONFERENCES_JSON_URL
        
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.isDiscretionary            = false
        
        let urlString   : String         = "\(url)"
        let session     : URLSession     = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl    : URL            = URL(string: urlString)!
        var request     : URLRequest     = URLRequest(url: finalUrl)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        do {
            let resp: (Data,URLResponse) = try await session.data(for: request)
            if let httpResponse = resp.1 as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let data    : Data = resp.0
                    var entries : [Conference]?
                    do {
                        var jsonDecoder: JSONDecoder {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .custom { decoder in
                                let container  = try decoder.singleValueContainer()
                                let dateString = try container.decode(String.self)
                                
                                if let date = DateFormatter.fullISO8601.date(from: dateString) {
                                    return date
                                }
                                if let date = DateFormatter.fullISO8601_without_Z.date(from: dateString) {
                                    return date
                                }
                                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Error parseJSONEntries cannot decode date string \(dateString)")
                            }
                            return decoder
                        }
                        entries = try jsonDecoder.decode([GlucoEntry].self, from: data)
                    } catch {
                        //print("Error parseJSONEntries (.fullISO8601 and .fullISO8601_without_Z): \(error)")
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .millisecondsSince1970
                            entries = try decoder.decode([GlucoEntry].self, from: data)
                        } catch {
                            //print("Error parseJSONEntries (.millisecondsSince1970): \(error)")
                        }
                    }
                    if entries == nil {
                        //debugPrint("Entries nil")
                    } else {
                        //debugPrint("Entries successfully updated")
                        return entries!
                    }
                } else {
                    //debugPrint("http response status code != 200")
                    return []
                }
            } else {
                //debugPrint("No valid http response")
                return []
            }
        } catch {
            //debugPrint("Error calling Nightscout API. Error: \(error.localizedDescription)")
            return []
        }
        return []
    }
    */
}
