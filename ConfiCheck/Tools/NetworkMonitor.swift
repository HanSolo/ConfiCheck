//
//  NetworkMonitor.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 27.12.24.
//

import Foundation
import Network


class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()

    var isConnected : Bool  = false {
        didSet {
            Task {
                self.isConnectedToInternet = await RestController.isConnected()
            }
        }
    }
    var isConnectedToInternet : Bool = false

    
    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue.global())
    }
}
