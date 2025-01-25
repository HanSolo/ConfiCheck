//
//  String+localized.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 08.01.25.
//

import Foundation


extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
