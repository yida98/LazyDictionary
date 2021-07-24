//
//  CameraView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-22.
//

import SwiftUI
import AVFoundation
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
                        .position(x: rect.origin.x,
                                  y: rect.origin.y)
                        .foregroundColor(Color.clear)
                        .clipped()
                }
            }
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.white)
                    Spacer()
                }
                Spacer()
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
                    
                    parent.viewModel.coords.append(bounds)
                    print("x: \(bounds.origin.x) y: \(bounds.origin.y) w: \(bounds.width) h: \(bounds.height)")
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
    
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var captureDeviceInput: AVCaptureDeviceInput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var videoOutput: AVCaptureVideoDataOutput?
    
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
        setupInputOutput()
        setupPreviewLayer()
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: AVCaptureDevice.Position.unspecified)
        for device in deviceDiscoverySession.devices {
            
            switch device.position {
            case AVCaptureDevice.Position.front:
                self.frontCamera = device
            case AVCaptureDevice.Position.back:
                self.backCamera = device
            default:
                break
            }
        }
        
        self.currentCamera = self.backCamera
    }
    
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            session.addInput(captureDeviceInput)
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput!.alwaysDiscardsLateVideoFrames = true
            videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoOutput!.setSampleBufferDelegate(delegate, queue: videoDataOutputQueue)
            
            session.addOutput(videoOutput!)
            
        } catch {
            print(error)
        }
        
    }
    
    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)

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
