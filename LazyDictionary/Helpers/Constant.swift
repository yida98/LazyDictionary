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
    
    static let fontName = "SF Pro Text"
    
    static let primaryColor: Color = .darkSkyBlue
    static let primaryColorDark: Color = .raisonBlack
    
    static let secondaryColor: Color = .thistle
    static let secondaryColorDark: Color = .moodPurple
    static let secondaryColorGrey: Color = .sonicSilver
    static let secondaryColorLight: Color = .magnolia
}

extension Color {
    static let lightGrey: Color = Color(white: 0.9)
    static let babyPowder: Color = Color(red: 252/255, green: 251/255, blue: 247/255)
    static let darkSkyBlue: Color = Color(red: 116/255, green: 179/255, blue: 206/255)
    static let raisonBlack: Color = Color(red: 57/255, green: 54/255, blue: 64/255)
    static let thistle: Color = Color(red: 213/255, green: 197/255, blue: 227/255)
    static let moodPurple: Color = Color(red: 130/255, green: 119/255, blue: 137/255)
    static let sonicSilver: Color = Color(red: 127/255, green: 121/255, blue: 121/255)
    static let magnolia: Color = Color(red: 248/255, green: 242/255, blue: 252/255)
}
