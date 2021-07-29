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
                    .frame(width: CameraViewModel.viewportSize.width,
                           height: CameraViewModel.viewportSize.height)
            } .position(x: Constant.screenBounds.width/2,
                        y: viewModel.trueCameraHeight/2)
            
            DictionaryView(viewModel: DictionaryViewModel(), word: $viewModel.word)
                .offset(y: viewModel.trueCameraHeight)
                
        }
        .ignoresSafeArea()
    }
}
