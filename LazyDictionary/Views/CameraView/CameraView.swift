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
                    .overlay(Text(viewModel.word)
                                .foregroundColor(Color.babyPowder)
                                .offset(y: CameraViewModel.viewportSize.height*0.5 + 16))
            } .position(x: Constant.screenBounds.width/2,
                        y: viewModel.trueCameraHeight/2 + 2)
            
            DictionaryView(viewModel: DictionaryViewModel(word: $viewModel.word))
                .offset(y: viewModel.trueCameraHeight - 34)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        viewModel.lookup()
                    } label: {
                        Text("Search")
                            .foregroundColor(.white)
                            .font(Font.custom("SF Pro Text", size: 20))
                            .fontWeight(.semibold)
                    }
                    .frame(width: CameraViewModel.buttonSize.width, height: CameraViewModel.buttonSize.height)
                    .background(Color.darkSkyBlue)
                    .padding(CameraViewModel.buttonPadding)
                    .mask(RoundedRectangle(cornerRadius: CameraViewModel.buttonCornerRadius)
                            .frame(width: CameraViewModel.buttonSize.width, height: CameraViewModel.buttonSize.height))
                }
            }
        }
        .ignoresSafeArea()
    }
}