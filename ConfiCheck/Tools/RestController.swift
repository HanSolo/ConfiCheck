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
    
    public static func fetchJavaChampions() async -> String {
        if let url = URL(string: Constants.JAVA_CHAMPIONS_YAML_URL) {
            do {
                let str  = try String(contentsOf: url, encoding: .utf8)
                //debugPrint("YAML: \(str)")
                return str
            } catch {
                debugPrint("JavaChampions yaml could not be loaded")
                return ""
            }
        } else {
            debugPrint("Bad url \(Constants.JAVA_CHAMPIONS_YAML_URL)")
            return ""
        }
    }
    
    public static func fetchJavaChampionsAttendence() async -> String {
        if let url = URL(string: Constants.JAVA_CHAMPIONS_ATTENDENCE_URL) {
            do {
                let str  = try String(contentsOf: url, encoding: .utf8)
                //debugPrint("YAML: \(str)")
                return str
            } catch {
                debugPrint("JavaChampions yaml could not be loaded")
                return ""
            }
        } else {
            debugPrint("Bad url \(Constants.JAVA_CHAMPIONS_YAML_URL)")
            return ""
        }
    }
    
    public static func createPullRequest(jsonTxt : String) -> Void {
        let data : Data = Data(jsonTxt.data(using: .utf8)!)
        //let data : NSMutableData = NSMutableData(data: jsonTxt.data(using: .utf8)!)
        let url  : URL  = URL(string: Constants.JAVA_CHAMPIONS_PR_URL)!
        let headers = [
            "Accept"               : "application/vnd.github+json",
            "Authorization"        : "Bearer \(Constants.BEARER_TOKEN)",
            "X-GitHub-Api-Version" : "2022-11-28",
            "Content-Type"         : "application/x-www-form-urlencoded"
        ]

        var request = URLRequest(url: url)
        request.httpMethod          = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody            = data as Data

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print(str ?? "")
            }
        }
        task.resume()
    }
    
    public static func createGithubPR(jsonTxt : String) async -> Void {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.isDiscretionary            = false
        
        let data        : Data            = Data(jsonTxt.data(using: .utf8)!)
        let urlString   : String          = "\(Constants.JAVA_CHAMPIONS_PR_URL)"
        let session     : URLSession      = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl    : URL             = URL(string: urlString)!
        let headers     : [String:String] = [
            "Accept"               : "application/vnd.github+json",
            "Authorization"        : "Bearer \(Constants.BEARER_TOKEN)",
            "X-GitHub-Api-Version" : "2022-11-28",
            "Content-Type"         : "application/x-www-form-urlencoded"
        ]
        var request     : URLRequest      = URLRequest(url: finalUrl)
        request.allHTTPHeaderFields = headers
        request.httpBody            = data as Data
        request.httpMethod          = "POST"
        
        do {
            let resp: (Data,URLResponse) = try await session.data(for: request)
            if let httpResponse = resp.1 as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    debugPrint("PR successfully created")
                } else {
                    debugPrint("Error creating PR, http response status code = \(httpResponse.statusCode)")
                }
            } else {
                debugPrint("No valid http response")
            }
        } catch {
            debugPrint("Error calling \(Constants.JAVA_CHAMPIONS_PR_URL). Error: \(error.localizedDescription)")
        }
    }
}
