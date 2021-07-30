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

extension Color {
    static let lightGrey: Color = Color(white: 0.9)
    static let babyPowder: Color = Color(red: 252/255, green: 251/255, blue: 247/255)
    static let darkSkyBlue: Color = Color(red: 116/255, green: 179/255, blue: 206/255)
    static let thistle: Color = Color(red: 213/255, green: 197/255, blue: 227/255)
}
