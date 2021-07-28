//
//  DictionaryView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-27.
//

import SwiftUI

struct DictionaryView: View {
    
    @ObservedObject var viewModel: DictionaryViewModel
    @Binding var word: String
    
    var body: some View {
        VStack {
            Text(word)
        }.frame(width: Constant.screenBounds.width, height: Constant.screenBounds.height, alignment: .center)
        .background(Color.lightGrey)
        .offset(y: Constant.screenBounds.height/3)
        
    }
}
