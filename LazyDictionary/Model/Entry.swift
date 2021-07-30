//
//  Entry.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-29.
//

import Foundation

struct RetrieveEntry: Codable {
    var metadata: Dictionary<String, String>?
    var results: Array<HeadwordEntry>?
}

class HeadwordEntry: NSObject, Codable, Identifiable {
    var id: String
    var language: String
    var lexicalEntries: Array<LexicalEntry>
    var pronunciations: Array<Pronunciation>?
    var type: String?
    var word: String
}

struct LexicalEntry: Codable {
    var entries: Array<Entry>
    var language: String
    var lexicalCategory: LexicalCategory
    var pronunciations: Array<Pronunciation>?
    var root: String?
    var text: String
}

struct Entry: Codable {
    var homographNumber: String?
    var senses: Array<Sense>?
}

struct Pronunciation: Codable {
    var audioFile: String?
    var dialects: Array<String>?
    var phoneticNotation: String?
    var phoneticSpelling: String?
    var regions: String?
    var registers: Array<String>?
}

struct LexicalCategory: Codable {
    var id: String
    var text: String
}

struct Sense: Codable {
    var definitions: Array<String>?
    var id: String?
    var subsenses: Array<Sense>?
}
