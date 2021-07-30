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
    
    @Published var coords: [CGRect] = [CGRect]()
    @Published var bufferSize: CGSize = CGSize(width: 1, height: 1) {
        willSet {
            trueCameraHeight = Constant.screenBounds.width / (newValue.height / newValue.width)
        }
    }
    
    @Published var trueCameraHeight: CGFloat = 1
    
    @Published var word: String = ""
    @Published var headwordEntry: HeadwordEntry? {
        willSet {
            loading = false
        }
    }
    @Published var loading: Bool = false
    
    static let viewportSize = CGSize(width: Constant.screenBounds.width * 0.3,
                                     height: 65)
    static let boundingBoxPadding: CGFloat = 4
    static let boundingBoxCornerRadius: CGFloat = 6
    
    static let buttonSize = CGSize(width: 90, height: 40)
    static let buttonPadding: CGFloat = 50
    static let buttonCornerRadius: CGFloat = 20
    
    func lookup() {
        if word != "" {
            loading = true
//
//            sleep(4)
//
//            loading = false
//
//            let subsense = Sense(definitions: ["(in tennis and similar games) a service that an opponent is unable to touch and thus wins a point"], id: "m_en_gbus0005680.013", subsenses: nil)
//            let sense1 = Sense(definitions: ["a playing card with a single spot on it, ranked as the highest card in its suit in most card games", "a person who excels at a particular sport or other activity"], id: "m_en_gbus0005680.006", subsenses: nil)
//            let sense2 = Sense(definitions: nil, id: "m_en_gbus0005680.010", subsenses: nil)
//            let sense3 = Sense(definitions: ["a pilot who has shot down many enemy aircraft, especially in World War I or World War II."], id: "m_en_gbus0005680.011", subsenses: [subsense])
//
//            let entry = Entry(homographNumber: nil, senses: [sense1, sense2, sense3])
//
//            let pronunciation = Pronunciation(audioFile: nil, dialects: nil, phoneticNotation: "respell", phoneticSpelling: "ās", regions: nil, registers: nil)
//            let pronunciation2 = Pronunciation(audioFile: nil, dialects: nil, phoneticNotation: "respell", phoneticSpelling: "āss", regions: nil, registers: nil)
//
//            let lexicalEntry = LexicalEntry(entries: [entry], language: "us-en", lexicalCategory: LexicalCategory(id: "noun", text: "Noun"), pronunciations: [pronunciation], root: nil, text: "ace")
//            let lexicalEntry2 = LexicalEntry(entries: [entry], language: "us-en", lexicalCategory: LexicalCategory(id: "adjective", text: "Adjective"), pronunciations: [pronunciation2], root: nil, text: "ace")
//
//            let hwEntry = HeadwordEntry(id: "1", language: "en-us", lexicalEntries: [lexicalEntry, lexicalEntry2], pronunciations: [pronunciation], type: nil, word: "ace")
//
//            headwordEntry = hwEntry

            URLTask.shared.post(word: word)
                .receive(on: RunLoop.main)
                .map {
                    let value = $0
                    self.loading = false
                    return value
                }
                .assign(to: &$headwordEntry)
        }
    }
    
    func removeEntry(indexSet: IndexSet) {
        Storage.shared.entries.remove(atOffsets: indexSet)
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
            
            
            request.recognitionLevel = .accurate
//            request.usesLanguageCorrection = true
//            request.recognitionLanguages = [
            
            // The origin point is a corner, not the centre point
            let height = (Constant.screenBounds.width / (parent.viewModel.bufferSize.height / parent.viewModel.bufferSize.width))
            let originX = (Constant.screenBounds.width - CameraViewModel.viewportSize.width) / 2
            let originY = (height - CameraViewModel.viewportSize.height)/2
            
            request.regionOfInterest = normalizeBounds(for: CGRect(origin: CGPoint(x: originX,
                                                                                   y: originY),
                                                                   size: CameraViewModel.viewportSize),
                                                       in: parent.viewModel.bufferSize)
//            let imageRequestHandler = VNImageRequestHandler(cgImage: imageFromSampleBuffer(sampleBuffer : sampleBuffer).cgImage!, options: [:])
//            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation.right, options: [:])
            
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
            rect.origin = CGPoint(x: rect.minX/width, y: rect.minY/height)
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
        
        func imageFromSampleBuffer(sampleBuffer : CMSampleBuffer) -> UIImage {
            // Get a CMSampleBuffer's Core Video image buffer for the media data
            let  imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            // Lock the base address of the pixel buffer
            CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)


            // Get the number of bytes per row for the pixel buffer
            let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)

            // Get the number of bytes per row for the pixel buffer
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
            // Get the pixel buffer width and height
            let width = CVPixelBufferGetWidth(imageBuffer!)
            let height = CVPixelBufferGetHeight(imageBuffer!)

            // Create a device-dependent RGB color space
            let colorSpace = CGColorSpaceCreateDeviceRGB()

            // Create a bitmap graphics context with the sample buffer data
            var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
            bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
            //let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
            let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            // Create a Quartz image from the pixel data in the bitmap graphics context
            let quartzImage = context?.makeImage()
            // Unlock the pixel buffer
            CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)

            // Create an image object from the Quartz image
            let image = UIImage.init(cgImage: quartzImage!)

            return image
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
        
//        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        
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
        
        if let result = closestTo(.bottom, in: results) {
            if let recognizedText = result.topCandidates(CameraViewController.maxCandidates).first {
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
    }
    
    private func closestTo(_ point: Point,in results: [VNRecognizedTextObservation]) -> VNRecognizedTextObservation? {
        return results.reduce(results.first) { result, observation in
            var prevDistance: Float = 0
            var currDistance: Float = 0
            guard let prev = result else {
                return observation
            }
            var pointX, pointY, prevX, prevY, currX, currY: Float
            
            switch point {
            case .top:
                pointX = 0.5
                pointY = 1
                prevX = Float(prev.boundingBox.midX)
                prevY = Float(prev.boundingBox.maxY)
                currX = Float(observation.boundingBox.midX)
                currY = Float(observation.boundingBox.maxY)
            case .bottom:
                pointX = 0.5
                pointY = 0
                prevX = Float(prev.boundingBox.midX)
                prevY = Float(prev.boundingBox.minY)
                currX = Float(observation.boundingBox.midX)
                currY = Float(observation.boundingBox.minY)
                
            default: // Centre case
                pointX = 0.5
                pointY = 0.5
                prevX = Float(prev.boundingBox.midX)
                prevY = Float(prev.boundingBox.midY)
                currX = Float(observation.boundingBox.midX)
                currY = Float(observation.boundingBox.midY)
            }
            
            prevDistance += (pointX - prevX).magnitude + (pointY - prevY).magnitude
            currDistance += (pointX - currX).magnitude + (pointY - currY).magnitude
            
//            print(prevDistance, prev.boundingBox.midX, prev.boundingBox.midY, currDistance, observation.boundingBox.midX, observation.boundingBox.midY)
            return prevDistance > currDistance ? observation : result
        }
    }
    
    
    fileprivate func boundingBox(forRegionOfInterest: CGRect, fromOutput size: CGSize) -> CGRect {
        
        let imageWidth = size.width
        let imageHeight = size.height
        
        let imageRatio = imageWidth / imageHeight
        let width = imageWidth
        let height = width / imageRatio
        
        // Begin with input rect.
        var rect = forRegionOfInterest
        
//        let bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let uiRotationTransform = CGAffineTransform(translationX: 1, y: 1).rotated(by: CGFloat.pi)
//        let transform = bottomToTopTransform.concatenating(uiRotationTransform)
        rect = rect.applying(uiRotationTransform)
        
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

//extension CGFloat
