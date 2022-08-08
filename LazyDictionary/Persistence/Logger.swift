//
//  Logger.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-29.
//

import Foundation

struct Logger {
    
    private static let fileName: URL = URL.getDocumentsDirectory().appendingPathComponent("log.txt")
    
    static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        return formatter
    }
    
    static func log(_ type: Logger.Key, message: String = "") {
        let log = "[\(type.rawValue.uppercased())] \(Logger.formatter.string(from: Date())): \(message)\n"
        
        do {
            try log.write(toFile: Logger.fileName.absoluteURL.path,
                          atomically: true,
                          encoding: String.Encoding.utf8)
        } catch {
            
        }
    }
    
    enum Key: String {
        case error
    }
    
}

extension URL {
    static func getDocumentsDirectory() -> URL {
        let directory = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        return directory[0]
    }
}
