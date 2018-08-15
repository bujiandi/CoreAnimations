//.
//  AnimationUtil.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/26.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import QuartzCore

private let kTransitionAnimation:String = "transitionAnimation"
private let kShakeAnimation:String = "shakeAnimation"
private let kShockAnimation:String = "shockAnimation"


extension CALayer {
    
    public func animate(transition style:TransitionStyle, from direction:TransitionDirection) {
        let transition = CATransition()
        transition.type = style.rawValue
        if !direction.rawValue.isEmpty {
            transition.subtype = direction.rawValue
        }
        transition.duration = 0.5
        transition.isRemovedOnCompletion = true
        removeAnimation(forKey: kTransitionAnimation)
        add(transition, forKey: kTransitionAnimation)
    }
    
    /// 摇晃动画
    public func animateShake(count:Float = 3) {
        let distance:CGFloat = 0.08        // 摇晃幅度
        animate(forKey: kShakeAnimation) {
            $0.transform.rotation.z
                .value(from: distance, to: -distance, duration: 0.1).by(0.003)
                .autoreverses(true).repeat(count: count).timingFunction(.easeInOut)
        }
    }
    
    /// 震荡动画
    public func animateShock(count:Float = 2) {
        let distance:CGFloat = 10        // 震荡幅度
        animate(forKey: kShockAnimation) {
            $0.transform.translation.x
                .values([0, -distance, distance, 0], duration: 0.15)
                .autoreverses(true).repeat(count: count).timingFunction(.easeInOut)
        }

    }
    
}
