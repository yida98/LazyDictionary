//
//  ScannerView.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-22.
//

import SwiftUI
import VisionKit
import Combine

struct ScannerView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) { }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let scannerView: ScannerView
        
        init(with scannerView: ScannerView) {
            self.scannerView = scannerView
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var scannedObjects = [UIImage]()
            
            for i in 0..<scan.pageCount {
                scannedObjects.append(scan.imageOfPage(at: i))
            }
            scannerView.didFinishScanning.send(scannedObjects)
        }
    
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    var didFinishScanning = PassthroughSubject<[UIImage], Error>()
}
