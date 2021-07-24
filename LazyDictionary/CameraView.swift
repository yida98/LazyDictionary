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
            CameraViewRepresentable(controller: $viewModel.controller, viewModel: viewModel)
                .ignoresSafeArea()
            GeometryReader { geometry in
                
                ForEach(viewModel.coords, id: \.self) { rect in
                    Rectangle()
                        .border(Color.red, width: 2)
                        .frame(width: rect.width,
                               height: rect.height)
                        .position(x: rect.origin.y,
                                  y: rect.origin.x)
                        .foregroundColor(Color.clear)
                        
                }
            }
//            Circle()
//                .frame(width: 300, height: 300)
//                .position(x: (Constant.screenBounds.width/2),
//                          y: (Constant.screenBounds.height/2))
//                .foregroundColor(Color.blue)
                
        }.frame(width: Constant.screenBounds.width,
                height: Constant.screenBounds.height)
        .ignoresSafeArea()
    }
}

struct CameraViewRepresentable: UIViewControllerRepresentable {
    @Binding var controller: CameraViewController
    var viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
//        let controller = CameraViewController()
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
        
        var sequenceHandler = VNSequenceRequestHandler()
        
        init(_ parent: CameraViewRepresentable) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            let captureRequest = VNDetectTextRectanglesRequest(completionHandler: detectText)
            do {
                try sequenceHandler.perform([captureRequest],
                                            on: pixelBuffer)
            } catch {
                debugPrint(error.localizedDescription)
            }
            
//            parent.viewModel.coords = [CGRect]()
        }
        
        private func detectText(request: VNRequest, error: Error?) {
                
                guard let results = request.results as? [VNTextObservation] else {
                    return
                }
                for result in results {
                    
                    let bounds = VNImageRectForNormalizedRect(result.boundingBox, Int(parent.controller.bufferSize.width), Int(parent.controller.bufferSize.height))
                    
//                    parent.viewModel.coords.append(bounds)
                    DispatchQueue.main.async {
                        self.parent.viewModel.coords.append(bounds)
                    }
                    print(parent.controller.bufferSize, result.boundingBox, Constant.screenBounds.size, bounds)
//                    print("x: \(bounds.origin.x) y: \(bounds.origin.y) w: \(bounds.width) h: \(bounds.height)")
    //                if Constant.centrePoint.x <= normalizedBounds.maxX &&
    //                    Constant.centrePoint.y <= normalizedBounds.maxY &&
    //                    Constant.centrePoint.x >= normalizedBounds.minX &&
    //                    Constant.centrePoint.y >= normalizedBounds.minY {
    //                }

                
            }
        }
    }
}

class CameraViewController: UIViewController {
    
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    var bufferSize: CGSize = .zero
    
    //DELEGATE
    var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    
    func startRunning() {
        session.startRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        setupDevice()
        setupPreviewLayer()
    }
    
    func startLiveVideo() {
        session.sessionPreset = .photo
        
        var deviceInput: AVCaptureDeviceInput!
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
    }
    
    func setupDevice() {
        
        var deviceInput: AVCaptureDeviceInput!
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // Model image size is smaller.
        
        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(delegate, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        
    }
    
    func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewLayer.frame = self.view.frame
        self.view.layer.insertSublayer(previewLayer, at: 0)

    }
    
}
extension CGImagePropertyOrientation {
    init(_ uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        }
    }
}
