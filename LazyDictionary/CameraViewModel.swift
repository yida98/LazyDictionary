//
//  CameraViewModel.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-22.
//

import Foundation
import Vision
import SwiftUI
import Combine

class CameraViewModel: ObservableObject {
    
    @Published var controller: CameraViewController = CameraViewController()
    @Published var coords: [CGRect] = [CGRect]()
    
    init() {
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
