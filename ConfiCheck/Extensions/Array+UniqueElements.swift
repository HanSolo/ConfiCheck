//
//  Array+UniqueElements.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 27.01.25.
//

import Foundation

extension Array where Element: Hashable {
  
    func uniqueElements() -> [Element] {
        var seen = Set<Element>()
        var out  = [Element]()
        for element in self {
            if !seen.contains(element) {
                out.append(element)
                seen.insert(element)
            }
        }
        return out
    }
    
    func unsortedUniqueElements() -> [Element] {
        let set = Set(self)
        return Array(set)
      }
}
