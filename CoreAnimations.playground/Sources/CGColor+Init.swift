//
//  NetStateView.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/24.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import QuartzCore

extension CGColorSpace {
    public static let deviceRGBA = CGColorSpaceCreateDeviceRGB()
    public static let deviceCMYK = CGColorSpaceCreateDeviceCMYK()
    public static let deviceGray = CGColorSpaceCreateDeviceGray()
}

//extension CGColor {
//    public convenience init?(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) {
//        var color = [red,green,blue,alpha]
//        self.init(colorSpace: .deviceRGBA, components: &color)
//    }
//}

extension CGColor {
    
    public static func device(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) -> CGColor? {
        var color = [red,green,blue,alpha]
        return CGColor(colorSpace: .deviceRGBA, components: &color)
    }
    
    public static func device(ARGB value:UInt32) -> CGColor? {
        let a:CGFloat = CGFloat((value >> 24) & 0xFF) / 0xFF
        let r:CGFloat = CGFloat((value >> 16) & 0xFF) / 0xFF
        let g:CGFloat = CGFloat((value >>  8) & 0xFF) / 0xFF
        let b:CGFloat = CGFloat((value >>  0) & 0xFF) / 0xFF
        var color = [r,g,b,a]
        return CGColor(colorSpace: .deviceRGBA, components: &color)
    }
}

extension CGColor {
    
    public static let white         = CGColor.device(ARGB: 0xFFFFFFFF)!
    public static let black         = CGColor.device(ARGB: 0xFF000000)!
    public static let whiteClean    = CGColor.device(ARGB: 0x00FFFFFF)!
    public static let blackClean    = CGColor.device(ARGB: 0x00000000)!
}

