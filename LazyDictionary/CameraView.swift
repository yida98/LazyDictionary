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
            Group {
                CameraViewRepresentable(viewModel: viewModel)
    
                ScannerView()
                    .environmentObject(viewModel)
            } .position(x: Constant.screenBounds.width/2,
                        y: ((Constant.screenBounds.width / (viewModel.bufferSize.height / viewModel.bufferSize.width))/2))
            
            DictionaryView(viewModel: DictionaryViewModel(), word: $viewModel.word)
                .offset(y: Constant.screenBounds.height * 0.8)
                
        }
        .ignoresSafeArea()
    }
}
