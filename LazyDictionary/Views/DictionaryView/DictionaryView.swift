//
//  DictionaryView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-27.
//

import SwiftUI

struct DictionaryView: View {
    
    @ObservedObject var viewModel: DictionaryViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.word)
            Spacer()
        }.frame(width: Constant.screenBounds.width,
                height: Constant.screenBounds.height,
                alignment: .center)
        .background(Color.lightGrey)
        
    }
}
