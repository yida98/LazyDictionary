//
//  URLTask.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-29.
//

import Foundation
import Combine

struct URLTask {
    
    static let shared = URLTask()
    
    private static let urlBase = "https://od-api.oxforddictionaries.com:443/api/v2/entries/"
    private static let appId = "b68e6b0c"
    private static let appKey = "925663b99eb05101c30ba2deea94cac6"

    static let default_language: URLTask.Language = .en_us
    
    var storage: Set<AnyCancellable> = Set<AnyCancellable>()
    
    func isEntry(word: String) -> Bool {
    
        return false
    }
    
    private mutating func post(word: String,
                       language: URLTask.Language = URLTask.default_language,
                       fields: Array<String> = ["definitions", "pronunciation"],
                       strictMatch: Bool = true) {
        let url = URL(string: URLTask.requestURL(for: word, in: language, fields: fields, strictMatch: strictMatch))!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(URLTask.appId, forHTTPHeaderField: "app_id")
        request.addValue(URLTask.appKey, forHTTPHeaderField: "app_key")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { try URLTask.parseResult(data: $0.data) }
            .sink { _ in print("completion") } receiveValue: { print($0.results?.first?.lexicalEntries.first?.lexicalCategory) }
            .store(in: &storage)
    }
    
    private static func parseResult(data: Data) throws -> RetrieveEntry {
        let jsonDecoder = JSONDecoder()
        do {
            let parsedJSON = try jsonDecoder.decode(RetrieveEntry.self, from: data)
            return parsedJSON
        } catch {
            throw error
        }
    }
    
    private static func requestURL(for word_id: String,
                                   in language: URLTask.Language = URLTask.default_language,
                                   fields: Array<String> = [],
                                   strictMatch: Bool = true) -> String {
        return "\(URLTask.urlBase)\(language.rawValue)/\(word_id.lowercased())?fields=\(fields.joined(separator: "%2C"))&strictMatch=\(strictMatch)"
    }
    
    enum Language: String {
        case en_us = "en-us"
        case en_gb = "en-gb"
        case es
        case fr
        case gu
        case hi
        case lv
        case ro
        case sw
        case ta
    }
}
