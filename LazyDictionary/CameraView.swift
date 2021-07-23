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
            ForEach(viewModel.coords, id: \.self) { rect in
                Rectangle()
                    .frame(width: rect.width, height: rect.height)
                    .foregroundColor(Color.clear)
                    .border(Color.red, width: 2)
                    .position(x: rect.minX, y: rect.minY)
                    .ignoresSafeArea()
            }
                
        }
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
                debugPrint("Screen: \(Constant.screenBounds.size) \n Centre: \(Constant.centrePoint)")
                let bounds = result.boundingBox
                let normalizedBounds = CGRect(x: bounds.minX *
                                                Constant.screenBounds.size.width,
                                              y: bounds.minY * Constant.screenBounds.size.height,
                                              width: bounds.width * Constant.screenBounds.size.width,
                                              height: bounds.height * Constant.screenBounds.size.height)
                debugPrint("Bounds: \(bounds)\n \(bounds.minY), \(bounds.maxY) Normalized:  \(normalizedBounds)")
                if Constant.centrePoint.x <= normalizedBounds.maxX &&
                    Constant.centrePoint.y <= normalizedBounds.maxY &&
                    Constant.centrePoint.x >= normalizedBounds.minX &&
                    Constant.centrePoint.y >= normalizedBounds.minY {
                    parent.viewModel.coords.append(normalizedBounds)
                }
            }
        }
    }
}

class CameraViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var videoOutput: AVCaptureVideoDataOutput?
    
    //DELEGATE
    var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    
    func startRunning() {
        captureSession.startRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
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
            captureSession.addInput(captureDeviceInput)
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput!.videoSettings = ["kCVPixelBufferPixelFormatTypeKey": "kCVPixelFormatType_32BGRA"]
            videoOutput!.setSampleBufferDelegate(delegate, queue: DispatchQueue.main)
            videoOutput!.alwaysDiscardsLateVideoFrames = true
            captureSession.addOutput(videoOutput!)
            
        } catch {
            print(error)
        }
        
    }
    
    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)

    }
    
//    func highlighWord(box: VNTextObservation) {
//        guard let boxes = box.characterBoxes else {
//            debugPrint("Cannot create character boxes")
//            return
//        }
//        let maxX: CGFloat = boxes.map { $0.bottomLeft.x }.max() ?? .infinity
//        let maxY: CGFloat = boxes.map { $0.bottomRight.y }.max() ?? .infinity
//        let minX: CGFloat = boxes.map { $0.bottomLeft.y }.min() ?? .zero
//        let minY: CGFloat = boxes.map { $0.bottomRight.y }.min() ?? .zero
//
//        let xCord = maxX * self.view.frame.size.width
//        let yCord = (1 - minY) * self.view.frame.size.height
//        let width = (minX - maxX) * self.view.frame.size.width
//        let height = (minY - maxY) * self.view.frame.size.height
//
//        let outline = CALayer()
//        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
//        outline.borderWidth = 2.0
//        outline.borderColor = UIColor.red.cgColor
//
//        self.view.layer.addSublayer(outline)
//    }
    
}
