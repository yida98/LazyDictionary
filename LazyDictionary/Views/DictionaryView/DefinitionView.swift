//
//  DefinitionView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-29.
//

import SwiftUI

struct DefinitionView: View {
    
    var word: HeadwordEntry
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            
            VStack(alignment: .leading) {
                Text(word.word)
                    .font(Font.custom(Constant.fontName, size: 40))
                    .fontWeight(.semibold)
                    .foregroundColor(Constant.secondaryColorDark)
                
                Text(DefinitionViewModel.phoneticString(for: word))
                    .font(Font.custom(Constant.fontName, size: 14))
                    .foregroundColor(Constant.primaryColorDark)
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading,spacing: 24) {
                    ForEach(word.lexicalEntries) { lexicalEntry in
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(lexicalEntry.lexicalCategory.text.capitalized)
                                .font(Font.system(.footnote, design: .monospaced))
                                .italic()
                                .padding(.horizontal, 4)
                                .padding(.vertical, 3)
                                .foregroundColor(Constant.secondaryColorDark)
                                .background(Constant.secondaryColorGrey.opacity(0.3))
                                .cornerRadius(5)
                            
                            ForEach(DefinitionViewModel.sense(of: lexicalEntry)) { sense in

                                if sense.definitions != nil {
                                    ForEach(sense.definitions!, id: \.self) { definition in
                                        Text("\(definition)")
                                            .font(Font.custom(Constant.fontName, size: 12))
                                            .foregroundColor(Constant.primaryColorDark)
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }.padding(.bottom, 120)
            .padding(.top, 30)
            
        })
    }
}

//struct DefinitionView_Previews: PreviewProvider {
//    static var previews: some View {
//        let subsense = Sense(definitions: ["(in tennis and similar games) a service that an opponent is unable to touch and thus wins a point"], id: "m_en_gbus0005680.013", subsenses: nil)
//        let sense1 = Sense(definitions: ["a playing card with a single spot on it, ranked as the highest card in its suit in most card games", "a person who excels at a particular sport or other activity"], id: "m_en_gbus0005680.006", subsenses: nil)
//        let sense2 = Sense(definitions: nil, id: "m_en_gbus0005680.010", subsenses: nil)
//        let sense3 = Sense(definitions: ["a pilot who has shot down many enemy aircraft, especially in World War I or World War II."], id: "m_en_gbus0005680.011", subsenses: [subsense])
//        
//        let entry = Entry(homographNumber: nil, senses: [sense1, sense2, sense3])
//        
//        let pronunciation = Pronunciation(audioFile: nil, dialects: nil, phoneticNotation: "respell", phoneticSpelling: "ās", regions: nil, registers: nil)
//        let lexicalEntry = LexicalEntry(entries: [entry], language: "us-en", lexicalCategory: LexicalCategory(id: "noun", text: "Noun"), pronunciations: [pronunciation], root: nil, text: "ace")
//        
//        
//        
//        let pronunciation2 = Pronunciation(audioFile: nil, dialects: nil, phoneticNotation: "respell", phoneticSpelling: "āss", regions: nil, registers: nil)
//        let lexicalEntry2 = LexicalEntry(entries: [entry], language: "us-en", lexicalCategory: LexicalCategory(id: "adjective", text: "Adjective"), pronunciations: [pronunciation2], root: nil, text: "ace")
//        let hwEntry = HeadwordEntry(id: "1", language: "en-us", lexicalEntries: [lexicalEntry, lexicalEntry2], pronunciations: [pronunciation], type: nil, word: "ace")
//        DefinitionView(word: hwEntry)
//    }
//}
