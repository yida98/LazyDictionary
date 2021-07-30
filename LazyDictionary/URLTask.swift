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
    
    private static let urlBase = "https://od-api.oxforddictionaries.com/api/v2/entries/"
    private static let appId = "b68e6b0c"
    private static let appKey = "925663b99eb05101c30ba2deea94cac6"
    
    private let cache: NSCache<NSURL, HeadwordEntry> = NSCache<NSURL, HeadwordEntry>()

    static let default_language: URLTask.Language = .en_us
    
    var storage: Set<AnyCancellable> = Set<AnyCancellable>()
    
    func post(word: String,
                       language: URLTask.Language = URLTask.default_language,
                       fields: Array<String> = ["definitions", "pronunciation"],
                       strictMatch: Bool = false) -> AnyPublisher<HeadwordEntry, Never> {
        let url = URL(string: URLTask.requestURL(for: word, in: language, fields: fields, strictMatch: strictMatch))!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(URLTask.appId, forHTTPHeaderField: "app_id")
        request.addValue(URLTask.appKey, forHTTPHeaderField: "app_key")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap {
                if $0.response is HTTPURLResponse {
                    return $0.data
                } else {
                    print("[ERROR] bad response")
                    throw NetworkError.badResponse
                }
            }
            .decode(type: RetrieveEntry.self, decoder: JSONDecoder())
            .tryMap {
                if let result = $0.results, let firstResult = result.first {
                    return firstResult
                } else {
                    print("[ERROR] no result")
                    throw LazyDictionaryError.noResult
                }
            }
            .handleEvents(receiveOutput: { [cache] entry in
                cache.setObject(entry, forKey: request.url! as NSURL)
            })
            .assertNoFailure("This shouldn't happen, right?")
            .eraseToAnyPublisher()
            
    }
    
    private static func requestURL(for word_id: String,
                                   in language: URLTask.Language = URLTask.default_language,
                                   fields: Array<String> = [],
                                   strictMatch: Bool = false) -> String {
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

enum NetworkError: Error {
    case badResponse
}

enum LazyDictionaryError: Error {
    case noResult
}
