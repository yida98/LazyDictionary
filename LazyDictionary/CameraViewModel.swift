//
//  CameraViewModel.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-22.
//

import Foundation
import Vision
import SwiftUI

class CameraViewModel: ObservableObject {
    
    @Published var controller: CameraViewController = CameraViewController()
    @Published var coords: [CGRect] = [CGRect]()
    
    init() {
        let initRect = CGRect(x: 23.6109375, y: 42.31111111111116, width: 9.703125000000004, height: 39.82222222222218)
        coords.append(initRect)
    }
//    let request = VNRecognizeTextRequest { request, error in
//        guard let observations = request.results as? [VNRecognizedTextObservation] else {
//            fatalError("Recevied invalid observations")
//        }
//        
//        for observation in observations {
//            guard let bestCandidate = observation.topCandidates(1).first else {
//                print("No candidate")
//                continue
//            }
//            
//            print("Found this candidate: \(bestCandidate)")
//        }
//        
//    }
    
//    func getWord() {
//        guard let cgImg = image.cgImage else {
//            debugPrint("Image unavailable")
//            return
//        }
//        let requestHandler = VNImageRequestHandler(cgImage: cgImg, options: [:])
//        let saliencyRequest = VNGenerateAttentionBasedSaliencyImageRequest { request, error in
//            guard let results = request.results as? [VNSaliencyImageObservation] else {
//                debugPrint("Cannot get result!")
//                return
//            }
//
//        }
        
//        guard let results = saliencyRequest.results?.first else{return}
//        let observations = results as? VNSaliencyImageObservation
//        let salientObjects = observation.salientObjects
//    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        
    }
}
