//
//  AnimationBisic.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/25.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import QuartzCore

open class AnimationBasic<T, Value> where T : CAAnimation {
    
    public let caAnimation:T
    
    public init(_ caAnimation:T) {
        self.caAnimation = caAnimation
    }
    
    /* The begin time of the object, in relation to its parent object, if
     * applicable. Defaults to 0. */
    @discardableResult
    public func delay(_ value:TimeInterval) -> Self {
        caAnimation.beginTime = value
        return self
    }
    
    /* A timing function defining the pacing of the animation. Defaults to
     * nil indicating linear pacing. */
    @discardableResult
    open func timingFunction(_ value:CAMediaTimingFunction) -> Self {
        caAnimation.timingFunction = value
        return self
    }
    
    /* When true, the animation is removed from the render tree once its
     * active duration has passed. Defaults to YES. */
    @discardableResult
    open func removedOnCompletion(_ value:Bool) -> Self {
        caAnimation.isRemovedOnCompletion = value
        return self
    }
    
    @discardableResult
    open func onStoped(_ completion: @escaping @convention(block) (Bool) -> Void) -> Self {
        if let delegate = caAnimation.delegate as? AnimationDelegate {
            delegate.onStoped = completion
        } else {
            caAnimation.delegate = AnimationDelegate(completion)
        }
        return self
    }
    
    @discardableResult
    open func onDidStart(_ started: @escaping @convention(block) () -> Void) -> Self {
        if let delegate = caAnimation.delegate as? AnimationDelegate {
            delegate.onDidStart = started
        } else {
            caAnimation.delegate = AnimationDelegate(started)
        }
        return self
    }
        
    /* The rate of the layer. Used to scale parent time to local time, e.g.
     * if rate is 2, local time progresses twice as fast as parent time.
     * Defaults to 1. */
    @discardableResult
    open func speed(_ value:Float) -> Self {
        caAnimation.speed = value
        return self
    }
    
    /* Additional offset in active local time. i.e. to convert from parent
     * time tp to active local time t: t = (tp - begin) * speed + offset.
     * One use of this is to "pause" a layer by setting `speed' to zero and
     * `offset' to a suitable value. Defaults to 0. */
    @discardableResult
    open func time(offset:CFTimeInterval) -> Self {
        caAnimation.timeOffset = offset
        return self
    }
    
    /* The repeat count of the object. May be fractional. Defaults to 0. */
    @discardableResult
    open func `repeat`(count:Float) -> Self {
        caAnimation.repeatCount = count
        return self
    }
    
    /* The repeat duration of the object. Defaults to 0. */
    @discardableResult
    open func `repeat`(duration:CFTimeInterval) -> Self {
        caAnimation.repeatDuration = duration
        return self
    }
    
    /* When true, the object plays backwards after playing forwards. Defaults
     * to NO. */
    @discardableResult
    open func autoreverses(_ value:Bool) -> Self {
        caAnimation.autoreverses = value
        return self
    }
    
    /* Defines how the timed object behaves outside its active duration.
     * Local time may be clamped to either end of the active duration, or
     * the element may be removed from the presentation. The legal values
     * are `backwards', `forwards', `both' and `removed'. Defaults to
     * `removed'. */
    @discardableResult
    open func fill(mode:AnimationFillMode) -> Self {
        caAnimation.fillMode = convertToCAMediaTimingFillMode(mode.rawValue)
        return self
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAMediaTimingFillMode(_ input: String) -> CAMediaTimingFillMode {
	return CAMediaTimingFillMode(rawValue: input)
}
