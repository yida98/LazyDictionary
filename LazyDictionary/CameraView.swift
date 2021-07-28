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
                          y: (Constant.screenBounds.height * viewModel.bufferSize.width/viewModel.bufferSize.height)/2)
                
                
            ForEach(viewModel.coords, id: \.self) { rect in
                Spacer()
                    .border(Color.red, width: 2)
                    .foregroundColor(Color.clear)
                    .frame(width: rect.width,
                           height: rect.height)
                    .position(x: rect.origin.x,
                              y: rect.origin.y)
                    
            }
//            Circle()
//                .frame(width: 300, height: 300)
//                .position(x: (Constant.screenBounds.width/2),
//                          y: (Constant.screenBounds.height/2))
//                .foregroundColor(Color.blue)
                
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
            
            var requestOptions:[VNImageOption : Any] = [:]
            
            if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
                requestOptions = [.cameraIntrinsics:camData]
            }
//            captureRequest.regionOfInterest = CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
//            captureRequest.reportCharacterBoxes = true
            
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation.rightMirrored, options: requestOptions)

            do {
                try imageRequestHandler.perform([request])
            } catch {
                print(error)
            }
            
//            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//                return
//            }
//            captureRequest.reportCharacterBoxes = true
//            do {
//                try sequenceHandler.perform([captureRequest],
//                                            on: pixelBuffer)
//            } catch {
//                debugPrint(error.localizedDescription)
//            }
            
//            parent.viewModel.coords = [CGRect]()
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
        
//        do {
//            try videoDevice!.lockForConfiguration()
//            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
//            bufferSize.width = CGFloat(dimensions.width)
//            bufferSize.height = CGFloat(dimensions.height)
//            videoDevice!.unlockForConfiguration()
//        } catch {
//            print(error)
//        }
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
        
            DispatchQueue.main.async { [self] in
                viewModel.coords = [CGRect]()
            }
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            print("no requests")
            return
        }
        for result in results {
            var bounds = result.boundingBox
            print("x: \(bounds.origin.x), y: \(bounds.origin.y), width: \(bounds.width), height: \(bounds.height)")
            
//                bounds = parent.controller.previewLayer.layerRectConverted(fromMetadataOutputRect: bounds)
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
        
//            let temp = rect.size.height
//            rect.size.height = rect.size.width
//            rect.size.width = temp
        
        rect.origin.y = (rect.origin.y * height) + (height / 2)
        rect.origin.x = (1 - rect.origin.x) * width
        
//            let tempO = rect.origin.x
//            rect.origin.x = rect.origin.y
//            rect.origin.y = tempO
        
        return rect
        
        // Reposition origin.
//            rect.origin.x *= imageWidth
//            rect.origin.x += bounds.origin.x
//            rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y
//
//            // Rescale normalized coordinates.
//            rect.size.width *= imageWidth
//            rect.size.height *= imageHeight
//
//            return rect
    }

}
