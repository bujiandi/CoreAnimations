//
//  AnimationMaker.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/25.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import QuartzCore

public class AnimationMaker<Layer, Value> where Layer : CALayer {
    public unowned let maker:AnimationsMaker<Layer>
    public let keyPath:String
    public init(maker:AnimationsMaker<Layer>, keyPath:String) {
        self.maker = maker
        self.keyPath = keyPath
    }
    /// 指定弹簧系数的 弹性动画
    @available(iOS 9.0, *)
    func animate(duration:TimeInterval, damping:CGFloat, from begin:Any?, to over:Any?) -> Animation<CASpringAnimation, Value> {
        let anim = CASpringAnimation(keyPath: keyPath)
        anim.damping    = damping
        anim.fromValue  = begin
        anim.toValue    = over
        anim.duration   = duration
        maker.append(anim)
        return Animation<CASpringAnimation, Value>(anim)
    }
    
    /// 指定起始和结束值的 基础动画
    func animate(duration:TimeInterval, from begin:Any?, to over:Any?) -> Animation<CABasicAnimation, Value> {
        let anim = CABasicAnimation(keyPath: keyPath)
        anim.fromValue  = begin
        anim.toValue    = over
        anim.duration   = duration
        maker.append(anim)
        return Animation<CABasicAnimation, Value>(anim)
    }
    
    /// 指定关键值的帧动画
    func animate(duration:TimeInterval, values:[Value]) -> Animation<CAKeyframeAnimation, Value> {
        let anim = CAKeyframeAnimation(keyPath: keyPath)
        anim.values     = values
        anim.duration   = duration
        maker.append(anim)
        return Animation<CAKeyframeAnimation, Value>(anim)
    }
    
    /// 指定引导线的帧动画
    func animate(duration:TimeInterval, path:CGPath) -> Animation<CAKeyframeAnimation, Value> {
        let anim = CAKeyframeAnimation(keyPath: keyPath)
        anim.path       = path
        anim.duration   = duration
        maker.append(anim)
        return Animation<CAKeyframeAnimation, Value>(anim)
    }
}

public class UnknowMaker<Layer, Value> where Layer : CALayer {
    public unowned let maker:AnimationsMaker<Layer>
    public let keyPath:String
    public init(maker:AnimationsMaker<Layer>, keyPath:String) {
        self.maker = maker
        self.keyPath = keyPath
    }
}
