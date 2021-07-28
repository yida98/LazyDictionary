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
import AVFoundation

class CameraViewModel: ObservableObject {
    
    @Published var coords: [CGRect] = [CGRect]() {
        willSet {
            print("will set: \(newValue)")
        }
    }
    @Published var bufferSize: CGSize = CGSize(width: 1, height: 1)
    
    @Published var word: String = ""
    
    
    static let viewportSize = CGSize(width: Constant.screenBounds.width/2, height: 50)
    
}



struct CameraViewRepresentable: UIViewControllerRepresentable {
    var viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.viewModel = viewModel
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.startRunning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let parent: CameraViewRepresentable
        
        var request: VNRecognizeTextRequest!
        var sequenceHandler = VNSequenceRequestHandler()
        
        init(_ parent: CameraViewRepresentable) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
            request.regionOfInterest = normalizeBounds(for: CGRect(origin: CGPoint(x: Constant.screenBounds.width/2,
                                                              y: ((Constant.screenBounds.width / (parent.viewModel.bufferSize.height / parent.viewModel.bufferSize.width))/2)),
                                                                   size: CameraViewModel.viewportSize),
                                                       in: parent.viewModel.bufferSize)
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation.rightMirrored, options: [:])

            do {
                try imageRequestHandler.perform([request])
            } catch {
                print(error)
            }
        }
        
        private func normalizeBounds(for regionOfInterest: CGRect, in bufferSize: CGSize) -> CGRect {
            
            var rect = regionOfInterest
            let width = Constant.screenBounds.width
            let height = width / (bufferSize.height / bufferSize.width)
            rect.origin = CGPoint(x: rect.origin.x/width, y: rect.origin.y/height)
            rect.size = CGSize(width: rect.size.width/width, height: rect.size.height/height)
            
            return rect
        }
        
        private func normalizeSize(for regionOfInterest: CGSize, in bufferSize: CGSize) -> CGSize {
            
            var size = regionOfInterest
            let width = Constant.screenBounds.width
            let height = width / (bufferSize.height / bufferSize.width)

            size = CGSize(width: size.width/width, height: size.height/height)
            
            return size
        }
        
    }
}

class CameraViewController: UIViewController {
    
    private let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let deviceOutput = AVCaptureVideoDataOutput()
    private static let maxCandidates = 1
    
    var bufferSize: CGSize = .zero
    
    var viewModel: CameraViewModel!
    
    //DELEGATE
    var delegate: CameraViewRepresentable.Coordinator?
    
    override func viewDidLoad() {
        self.delegate!.request = VNRecognizeTextRequest(completionHandler: detectText)
        
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        startLiveVideo()
    }
    
    func startRunning() {
        session.startRunning()
    }
    
    func startLiveVideo() {
        session.sessionPreset = .vga640x480
        viewModel.bufferSize = CGSize(width: 640, height: 480)
        
        var deviceInput: AVCaptureDeviceInput!
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        
        deviceOutput.alwaysDiscardsLateVideoFrames = true
        deviceOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue.global())
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        if let previewLayerConnection = previewLayer.connection {
            previewLayerConnection.videoOrientation = .portrait
        }
        
        if let deviceConnection = deviceOutput.connection(with: .video) {
            deviceConnection.isEnabled = true
            deviceConnection.preferredVideoStabilizationMode = .off
        }
        
//        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = self.view.frame
        self.view.layer.insertSublayer(previewLayer, at: 0)
    
    }

    private func detectText(request: VNRequest, error: Error?) {
        if error != nil {
            print(error.debugDescription)
            return
        }
        DispatchQueue.main.async { [self] in
            viewModel.coords = [CGRect]()
        }
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            print("no requests")
            return
        }
        
        for result in results {
            
            guard let recognizedText = result.topCandidates(CameraViewController.maxCandidates).first else {
                continue
            }
            
            var bounds = result.boundingBox
            
            if viewModel != nil {
                DispatchQueue.main.async { [self] in
                    bounds = boundingBox(forRegionOfInterest: bounds, fromOutput: CameraViewModel.viewportSize)
                    viewModel.coords.append(bounds)
                    viewModel.word = recognizedText.string
                }
            }
            
        }
        
    }
    
    
    fileprivate func boundingBox(forRegionOfInterest: CGRect, fromOutput size: CGSize) -> CGRect {
        
        let imageWidth = size.width
        let imageHeight = size.height
        
        let imageRatio = imageWidth / imageHeight
        let width = Constant.screenBounds.width
        let height = width / imageRatio
        
        // Begin with input rect.
        var rect = forRegionOfInterest
        
        rect.size.height *= height
        rect.size.width *= width
        
        rect.origin.x = (rect.origin.x) * width
        rect.origin.y = rect.origin.y * height
        
        return rect
    }

}


extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        
    }
}
