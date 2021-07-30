//
//  UserDefault.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-29.
//

import Foundation
import Combine

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: UserDefault.Keys
    let defaultValue: Value
    var container: UserDefaults = .standard
    
    init(_ key: UserDefault.Keys, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: Value {
        get {
            let obj = container.object(forKey: key.rawValue)
            if let valueObj = obj as? Value {
                return valueObj
            } else if let dataObj = obj as? Data {
                do {
                    return try JSONDecoder().decode(Value.self, from: dataObj)
                } catch {
                    Logger.log(.error, message: error.localizedDescription)
                }
            }
            return defaultValue
        }
        set {
            if let _ = newValue as? PropertyListValue {
                container.setValue(newValue, forKey: key.rawValue)
            } else {
                let jsonData = try! JSONEncoder().encode(newValue)
                container.setValue(jsonData, forKey: key.rawValue)
            }
        }
    }
    
    enum Keys: String {
        case entry
    }
}

final class Storage: ObservableObject {
    
    static let shared = Storage()
    
    var objectWillChange = PassthroughSubject<Void, Never>()
    
    @UserDefault(.entry, defaultValue: [RetrieveEntry]())
    var entries: [RetrieveEntry] {
        willSet {
            objectWillChange.send()
        }
    }
    
}

protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Date: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}

// Every element must be a property-list type
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}

