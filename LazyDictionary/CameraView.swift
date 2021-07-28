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
                
                
        }
        .ignoresSafeArea()
    }
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
            
//            request.regionOfInterest = CGRect(origin: <#T##CGPoint#>, size: <#T##CGSize#>)
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation.rightMirrored, options: [:])

            do {
                try imageRequestHandler.perform([request])
            } catch {
                print(error)
            }
        }
        
    }
}

class CameraViewController: UIViewController {
    
    private let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let deviceOutput = AVCaptureVideoDataOutput()
    
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
            var bounds = result.boundingBox
            
            if viewModel != nil {
                DispatchQueue.main.async { [self] in
                    bounds = boundingBox(forRegionOfInterest: bounds, fromOutput: viewModel.bufferSize)
                    viewModel.coords.append(bounds)
                }
            }
            
        }
        
    }
    
    
    fileprivate func boundingBox(forRegionOfInterest: CGRect, fromOutput size: CGSize) -> CGRect {
        
        let imageWidth = size.height
        let imageHeight = size.width
        
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
