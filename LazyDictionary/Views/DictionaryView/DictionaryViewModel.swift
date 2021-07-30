//
//  DictionaryViewModel.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-27.
//

import Foundation
import SwiftUI

class DictionaryViewModel: ObservableObject {
    @Binding var word: String
    
    init(word: Binding<String>) {
        self._word = word
    }

}
