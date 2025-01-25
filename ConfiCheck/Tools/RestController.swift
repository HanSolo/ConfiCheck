//
//  RestController.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 26.12.24.
//

import Foundation
import Network
import SwiftUI


class RestController {
    public static func isConnected() async -> Bool {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = 2.0
        sessionConfig.timeoutIntervalForResource = 2.0
        
        let urlString : String      = "https://apple.com"
        let session   : URLSession  = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL         = URL(string: urlString)!
        var request   : URLRequest  = URLRequest(url: finalUrl)
        request.httpMethod = "HEAD"
        do {
            let resp : (Data,URLResponse) = try await session.data(for: request)
            
            if let httpResponse = resp.1 as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    public static func fetchJavaConferences() async -> [JavaConference] {
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
    
    public static func fetchDeveloperEvents() async -> [DeveloperEvent] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.isDiscretionary            = false
        
        let urlString   : String         = "\(Constants.DEVELOPER_EVENTS_JSON_URL)"
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
                    var result : [DeveloperEvent]?
                    do {
                        let jsonDecoder : JSONDecoder = JSONDecoder()
                        result = try jsonDecoder.decode([DeveloperEvent].self, from: data)
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
            debugPrint("Error calling \(Constants.DEVELOPER_EVENTS_JSON_URL). Error: \(error.localizedDescription)")
            return []
        }
    }
}
