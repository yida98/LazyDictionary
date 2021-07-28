//
//  Constant.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-23.
//

import Foundation
import SwiftUI

struct Constant {
    static let screenBounds: CGRect = UIWindow().screen.bounds
    static let centrePoint: CGPoint = CGPoint(x: Constant.screenBounds.midX,
                                     y: Constant.screenBounds.midY)
}
