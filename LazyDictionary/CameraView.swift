//
//  CameraView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-22.
//

import SwiftUI
import AVFoundation
import Combine
import Vision

struct CameraView: View {
    
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        
        ZStack {
            CameraViewRepresentable(viewModel: viewModel)
//                    .frame(width: 160, height: 120)
                .position(x: Constant.screenBounds.width/2,
                          y: ((Constant.screenBounds.width / (viewModel.bufferSize.height / viewModel.bufferSize.width))/2))
                
                
            ForEach(viewModel.coords, id: \.self) { rect in
                Spacer()
                    .border(Color.red, width: 2)
                    .foregroundColor(Color.clear)
                    .frame(width: rect.width,
                           height: rect.height)
                    .position(x: rect.midX,
                              y: rect.midY)
                    
            }
            Rectangle()
                .border(Color.blue, width: 1)
                .foregroundColor(Color.clear)
                .frame(width: CameraViewModel.viewportSize.width,
                       height: CameraViewModel.viewportSize.height)
                .position(x: (Constant.screenBounds.width/2),
                          y: (Constant.screenBounds.width / (viewModel.bufferSize.height / viewModel.bufferSize.width))/2)
                
            DictionaryView(viewModel: DictionaryViewModel(), word: $viewModel.word)
                
        }
        .ignoresSafeArea()
    }
}
