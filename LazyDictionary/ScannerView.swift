//
//  ScannerView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-22.
//

import SwiftUI
import VisionKit
import Combine

struct ScannerView: View {
    
    @EnvironmentObject var viewModel: CameraViewModel
    
    var body: some View {
        ZStack {
            ForEach(viewModel.coords, id: \.self) { rect in
                Rectangle()
                    .border(Color.red, width: 2)
                    .foregroundColor(Color.clear)
                    .frame(width: rect.width,
                           height: rect.height)
                    .position(x: rect.midX,
                              y: rect.midY)
            }
        }.background(Rectangle()
                        .border(width: 2, edges: [.bottom])
                        .foregroundColor(Color.clear)
                        .frame(width: CameraViewModel.viewportSize.width,
                               height: CameraViewModel.viewportSize.height)
        )

    }
    
}
