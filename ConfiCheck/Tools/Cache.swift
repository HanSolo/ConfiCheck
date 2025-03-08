//
//  Cache.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 06.03.25.
//

import Foundation

public class Cache {
        
    static  let shared        : Cache          = Cache()
    private var javaChampions : [JavaChampion] = []

    private init() {
        Task {
            let yaml               : String         = await RestController.fetchJavaChampions()
            let javaChampionsFound : [JavaChampion] = Helper.getJavaChampionsFromYaml(yaml: yaml)
            for javaChampion in javaChampionsFound {
                self.javaChampions.append(javaChampion)
            }
        }
    }
    
    
    public func getJavaChampions() async -> [JavaChampion] {
        if javaChampions.isEmpty {
            let yaml               : String         = await RestController.fetchJavaChampions()
            let javaChampionsFound : [JavaChampion] = Helper.getJavaChampionsFromYaml(yaml: yaml)
            for javaChampion in javaChampionsFound {
                self.javaChampions.append(javaChampion)
            }
        }
        return self.javaChampions
    }
    
    public func updateJavaChampions() async -> Void {
        let yaml               : String         = await RestController.fetchJavaChampions()
        let javaChampionsFound : [JavaChampion] = Helper.getJavaChampionsFromYaml(yaml: yaml)
        if !javaChampionsFound.isEmpty {
            self.javaChampions.removeAll()
            for javaChampion in javaChampionsFound {
                self.javaChampions.append(javaChampion)
            }
        }
    }
}
