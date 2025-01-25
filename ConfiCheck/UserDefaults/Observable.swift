//
//  Observable.swift
//  GlucoTracker
//
//  Created by Gerrit Grunwald on 03.08.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

struct Observable<T> {
    typealias Observer = String

    private var observers: [Observer: (T) -> Void] = [:]

    var value: T {
        didSet {
            observers.forEach { $0.value(value) }
        }
    }

    init(_ value: T) {
        self.value = value
    }

    @discardableResult
    mutating func addObserver(_ observer: @escaping (T) -> Void) -> Observer {
        let key = UUID().uuidString as Observer
        observers[key] = observer
        return key
    }

    mutating func removeObserver(_ key: Observer) {
        observers.removeValue(forKey: key)
    }
}
