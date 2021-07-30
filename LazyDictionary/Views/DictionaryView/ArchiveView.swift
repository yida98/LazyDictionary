//
//  ArchiveView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-29.
//

import SwiftUI

struct ArchiveView: View {
    
    @EnvironmentObject var viewModel: CameraViewModel
    @ObservedObject var storage: Storage = Storage.shared
    
    var body: some View {
        VStack {
            Text("Vocabulary")
                .font(Font.system(.title))
            List {
                ForEach(storage.entries) { entry in
                    Text(entry.word)
                }.onDelete { indexSet in
                    viewModel.removeEntry(indexSet: indexSet)
                }
            }
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}
