//
//  DefinitionViewModel.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-29.
//

import Foundation

class DefinitionViewModel {
    
    static func phoneticString(for word: HeadwordEntry) -> String {
        var phoneticSet = Set<String>()
        for entry in word.lexicalEntries {
            if let p = entry.pronunciations {
                p.map { $0.phoneticSpelling }.forEach { if $0 != nil { phoneticSet.insert($0!) } }
            }
        }
        // TODO: No pronunciation
        return "/  \(Array(phoneticSet).joined(separator: ", "))  /"
    }
    
    static func sense(of lexicalEntry: LexicalEntry) -> [Sense] {
        return lexicalEntry.entries.compactMap { $0.senses }.flatMap { $0 }
    }
}
