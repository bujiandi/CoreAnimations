//
//  AnimationsMaker.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/25.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import QuartzCore

open class AnimationsMaker<Layer> : AnimationBasic<CAAnimationGroup, CGFloat> where Layer : CALayer {
    
    public let layer:Layer
    
    public init(layer:Layer) {
        self.layer = layer
        super.init(CAAnimationGroup())
    }
    
    internal var animations:[CAAnimation] = []
    open func append(_ animation:CAAnimation) {
        animations.append(animation)
    }
    
    internal var _duration:CFTimeInterval?
    
    /* The basic duration of the object. Defaults to 0. */
    @discardableResult
    open func duration(_ value:CFTimeInterval) -> Self {
        _duration = value
        return self
    }
}
