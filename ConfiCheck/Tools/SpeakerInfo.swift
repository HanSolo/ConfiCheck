//
//  SpeakerInfo.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 28.01.25.
//

import Foundation
import SwiftUI
import CoreTransferable


struct SpeakerInfo: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
    
    public var image      : Image
    public var name       : String
    public var blueskyId  : String
    public var bio        : String
    public var experience : String
}
