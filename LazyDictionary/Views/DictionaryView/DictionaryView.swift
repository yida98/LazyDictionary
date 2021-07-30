//
//  DictionaryView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-27.
//

import SwiftUI

struct DictionaryView: View {
    
    @EnvironmentObject var viewModel: CameraViewModel
    @ObservedObject var storage: Storage = Storage.shared
    
    var body: some View {
        VStack {
            SearchView()
                .environmentObject(viewModel)
            
            ArchiveView()
                .environmentObject(viewModel)
            Spacer()
        }
        .background(Color.thistle)
        .frame(width: Constant.screenBounds.width,
                height: Constant.screenBounds.height)
        .cornerRadius(30)
        
    }
}
