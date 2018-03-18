//
//  GraphicsOperator.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/26.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import CoreGraphics


extension CATransform3D {
    
    public init() {
        self = CATransform3DIdentity
    }
    
    public func scale(sx:CGFloat = 1, sy:CGFloat = 1, sz:CGFloat = 1) -> CATransform3D {
        return CATransform3DScale(self, sx, sy, sz)
    }
    
    public func translation(tx:CGFloat = 0, ty:CGFloat = 0, tz:CGFloat = 0) -> CATransform3D {
        return CATransform3DTranslate(self, tx, ty, tz)
    }
    
    public func rotation(radian:CGFloat, x:CGFloat = 1, y:CGFloat = 1, z:CGFloat = 1) -> CATransform3D {
        return CATransform3DRotate(self, radian, x, y, z)
    }
}
