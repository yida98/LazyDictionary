//
//  DictionaryView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-27.
//

import SwiftUI

struct DictionaryView: View {
    
    @EnvironmentObject var parent: CameraViewModel
    @ObservedObject var storage: Storage = Storage.shared
    
    var body: some View {
        ZStack {
            VStack {
                Text(parent.word)
                
                Text("Vocabulary")
                    .font(Font.system(.title))
                List {
                    ForEach(storage.entries) { entry in
                        Text(entry.word)
                    }.onDelete { indexSet in
                        parent.removeEntry(indexSet: indexSet)
                    }
                }
                Spacer()
            }

        }
        .background(Color.thistle)
        .frame(width: Constant.screenBounds.width,
                height: Constant.screenBounds.height)
        .cornerRadius(30)
        
    }
}
