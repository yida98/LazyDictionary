//
//  SearchView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-29.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack {
            if viewModel.loading {
                Text("Fetching...")
            } else {
                if viewModel.headwordEntry == nil {
                    VStack(alignment: .center) {
                        Text("No Result")
                            .font(Font.custom(Constant.fontName, size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.gray)
                    }
                } else {
                    DefinitionView(word: viewModel.headwordEntry!)
                }
            }
        }.padding(60)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
