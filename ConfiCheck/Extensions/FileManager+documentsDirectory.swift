//
//  FileManager+documentsDirectory.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 27.01.25.
//

import Foundation


extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
