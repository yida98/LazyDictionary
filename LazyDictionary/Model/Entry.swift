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
    
    init(id: String, language: String, lexicalEntries: [LexicalEntry], pronunciations: [Pronunciation]?, type: String?, word: String) {
        self.id = id
        self.language = language
        self.lexicalEntries = lexicalEntries
        self.pronunciations = pronunciations
        self.type = type
        self.word = word
    }
}

struct LexicalEntry: Codable, Identifiable {
    var entries: Array<Entry>
    var language: String
    var lexicalCategory: LexicalCategory
    var pronunciations: Array<Pronunciation>?
    var root: String?
    var text: String
    var id: String {
        return text
    }
    
    init(entries: Array<Entry>, language: String, lexicalCategory: LexicalCategory, pronunciations: [Pronunciation]?, root: String?, text: String) {
        self.entries = entries
        self.language = language
        self.lexicalCategory = lexicalCategory
        self.pronunciations = pronunciations
        self.root = root
        self.text = text
    }
    
}

struct Entry: Codable, Identifiable {
    var homographNumber: String?
    var senses: Array<Sense>?
    var id: String {
        return homographNumber ?? UUID().uuidString
    }
    
    init(homographNumber: String?, senses: [Sense]) {
        self.homographNumber = homographNumber
        self.senses = senses
    }
}

struct Pronunciation: Codable {
    var audioFile: String?
    var dialects: Array<String>?
    var phoneticNotation: String?
    var phoneticSpelling: String?
    var regions: String?
    var registers: Array<String>?
    
    init(audioFile: String?, dialects: Array<String>?, phoneticNotation: String?, phoneticSpelling: String?, regions: String?, registers: [String]?) {
        self.audioFile = audioFile
        self.dialects = dialects
        self.phoneticNotation = phoneticNotation
        self.phoneticSpelling = phoneticSpelling
        self.regions = regions
        self.registers = registers
    }
}

struct LexicalCategory: Codable, Identifiable {
    var id: String
    var text: String
    
    init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}

struct Sense: Codable, Identifiable {
    var definitions: Array<String>?
    var id: String?
    var subsenses: Array<Sense>?
    
    init(definitions: [String]?, id: String?, subsenses: [Sense]?) {
        self.definitions = definitions
        self.id = id
        self.subsenses = subsenses
    }
}
