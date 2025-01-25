//
//  ObjectSaveable.swift
//  Navigator
//
//  Created by Gerrit Grunwald on 25.12.23.
//

import Foundation


protocol ObjectSaveable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}
