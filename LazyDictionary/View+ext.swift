//
//  View+ext.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-22.
//

import Foundation
import SwiftUI

extension View {
    func snapshot(bounds: CGRect) -> UIImage {
        let controller = UIHostingController(rootView: self)
        controller.view.bounds = bounds
        return controller.view.snapshot()
    }
}

extension UIView {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { context in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
//            layer.render(in: context.cgContext)
        }
    }
}
