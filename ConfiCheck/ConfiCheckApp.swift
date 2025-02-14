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
    
    let model    : ConfiModel      = ConfiModel()
    var container: ModelContainer? = {
         do {
             let configuration : ModelConfiguration = ModelConfiguration(Constants.CONTAINER_ID)
             let schema        : Schema             = Schema([ConferenceItem.self, ProposalItem.self])
             let container     : ModelContainer     = try ModelContainer(for: schema, configurations: [configuration])             
             return container
         } catch {
             print("Error creating ConfiCheck container: \(error)")
             return nil
         }
     }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .modelContainer(container!)
        }.onChange(of: phase) {
            switch phase {
            case .active     : break
            case .inactive   : break
            case .background : scheduleAppRefresh()
            default          : break
            }
        }
        .backgroundTask(.appRefresh(Constants.APP_REFRESH_ID)) {
            debugPrint("App refresh started in background")
            
            let javaConferences : [JavaConference] = await fetchJavaConferences(taskId: Constants.APP_REFRESH_ID)
            if Task.isCancelled {
                //debugPrint("Task was cancelled")
            } else {
                if (javaConferences.count > 0) {
                    await MainActor.run {
                        self.model.conferences.removeAll()
                        for javaConference in javaConferences {
                            let conference : ConferenceItem = JavaConference.convertToConferenceItem(javaConference: javaConference)
                            if javaConference.date == nil { continue }
                            self.model.conferences.append(conference)
                        }
                        self.model.update.toggle()
                        
                        Helper.storeConferencesThisMonthToUserDefaults(conferencesPerMonth: self.model.conferencesPerMonth, attendence: self.model.attendence)                        
                        WidgetCenter.shared.reloadAllTimelines()
                        
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
        
    func fetchJavaConferences(taskId: String) async -> [JavaConference] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.isDiscretionary            = false
        
        let urlString   : String         = "\(Constants.JAVA_CONFERENCES_JSON_URL)"
        let session     : URLSession     = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl    : URL            = URL(string: urlString)!
        var request     : URLRequest     = URLRequest(url: finalUrl)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        //debugPrint(urlString)
        
        do {
            let resp: (Data,URLResponse) = try await session.data(for: request)
            if let httpResponse = resp.1 as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let data   : Data = resp.0
                    var result : [JavaConference]?
                    do {
                        let jsonDecoder : JSONDecoder = JSONDecoder()
                        result = try jsonDecoder.decode([JavaConference].self, from: data)
                    } catch {
                        print("Error parseJSONEntries: \(error)")
                    }
                    return result ?? []
                } else {
                    debugPrint("http response status code != 200")
                    return []
                }
            } else {
                debugPrint("No valid http response")
                return []
            }
        } catch {
            debugPrint("Error calling \(Constants.JAVA_CONFERENCES_JSON_URL). Error: \(error.localizedDescription)")
            return []
        }
    }        
}
