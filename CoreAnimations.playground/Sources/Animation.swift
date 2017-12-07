//
//  Animation.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/25.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import QuartzCore

public enum AnimationFillMode : String {
    case backwards
    case forwards
    case both
    case removed
}

public final class Animation<T, Value> : AnimationBasic<T, Value> where T : CAAnimation {
    
    /* The basic duration of the object. Defaults to 0. */
    @discardableResult
    public func duration(_ value:CFTimeInterval) -> Self {
        caAnimation.duration = value
        return self
    }
    
}

// 如果只扩展 Animation, Basic里的链式语法 . 不出来扩展属性
extension Animation where T : CAPropertyAnimation {
    
    //更新值 这样设置测试没有效果
//    @discardableResult
//    public func updateValue(_ value:Value) -> Self {
//        guard let path = caAnimation.keyPath else {
//            print("caAnimation:\(caAnimation) keyPath is nil")
//            return self
//        }
//        caAnimation.setValue(value, forKeyPath: path)
//        return self
//    }
    
    /* When true the value specified by the animation will be "added" to
     * the current presentation value of the property to produce the new
     * presentation value. The addition function is type-dependent, e.g.
     * for affine transforms the two matrices are concatenated. Defaults to
     * NO. */
    @discardableResult
    public func additive(_ value:Bool) -> Self {
        caAnimation.isAdditive = value
        return self
    }
    
    /* The `cumulative' property affects how repeating animations produce
     * their result. If true then the current value of the animation is the
     * value at the end of the previous repeat cycle, plus the value of the
     * current repeat cycle. If false, the value is simply the value
     * calculated for the current repeat cycle. Defaults to NO. */
    @discardableResult
    public func cumulative(_ value:Bool) -> Self {
        caAnimation.isCumulative = value
        return self
    }
    
    /* If non-nil a function that is applied to interpolated values
     * before they are set as the new presentation value of the animation's
     * target property. Defaults to nil. */
    @discardableResult
    public func valueFunction(_ value:CAValueFunction) -> Self {
        caAnimation.valueFunction = value
        return self
    }
}

extension Animation where T : CABasicAnimation {
    
    //更新值 这样设置测试没有效果
//    @discardableResult
//    public func updateValue() -> Self {
//        guard let path = caAnimation.keyPath else {
//            print("caAnimation:\(caAnimation) keyPath is nil")
//            return self
//        }
//        caAnimation.setValue(caAnimation.toValue, forKeyPath: path)
//        return self
//    }

    @discardableResult
    public func from(_ value:Value) -> Self {
        caAnimation.fromValue = value
        return self
    }
    
    @discardableResult
    public func to(_ value:Value) -> Self {
        caAnimation.toValue = value
        return self
    }
    
    /* - `byValue' non-nil. Interpolates between the layer's current value
     * of the property in the render tree and that plus `byValue'. */
    @discardableResult
    public func by(_ value:Value) -> Self {
        caAnimation.byValue = value
        return self
    }
}

@available(iOSApplicationExtension 9.0, *)
extension Animation where T : CASpringAnimation {
    /* The mass of the object attached to the end of the spring. Must be greater
     than 0. Defaults to one. */
    /// 质量 默认1 必须>0 越重回弹越大
    @available(iOS 9.0, *)
    @discardableResult
    public func mass(_ value:CGFloat) -> Self {
        caAnimation.mass = value
        return self
    }
    
    /* The spring stiffness coefficient. Must be greater than 0.
     * Defaults to 100. */
    /// 弹簧钢度系数 默认100 必须>0 越小回弹越大
    @available(iOS 9.0, *)
    @discardableResult
    public func stiffness(_ value:CGFloat) -> Self {
        caAnimation.stiffness = value
        return self
    }
    
    /* The damping coefficient. Must be greater than or equal to 0.
     * Defaults to 10. */
    /// 阻尼 默认10 必须>=0
    @available(iOS 9.0, *)
    @discardableResult
    public func damping(_ value:CGFloat) -> Self {
        caAnimation.damping = value
        return self
    }
    
    /* The initial velocity of the object attached to the spring. Defaults
     * to zero, which represents an unmoving object. Negative values
     * represent the object moving away from the spring attachment point,
     * positive values represent the object moving towards the spring
     * attachment point. */
    /// 初速度 默认 0, 正数表示正方向的初速度, 负数表示反方向的初速度
    @available(iOS 9.0, *)
    @discardableResult
    public func initialVelocity(_ value:CGFloat) -> Self {
        caAnimation.initialVelocity = value
        return self
    }

}

extension Animation where T : CAKeyframeAnimation {
    
//    /* An array of objects providing the value of the animation function for
//     * each keyframe. */
//
//    @property(nullable, copy) NSArray *values;
//
//    /* An optional path object defining the behavior of the animation
//     * function. When non-nil overrides the `values' property. Each point
//     * in the path except for `moveto' points defines a single keyframe for
//     * the purpose of timing and interpolation. Defaults to nil. For
//     * constant velocity animation along the path, `calculationMode' should
//     * be set to `paced'. Upon assignment the path is copied. */
//
//    @property(nullable) CGPathRef path;
    
//    /* An optional array of `NSNumber' objects defining the pacing of the
//     * animation. Each time corresponds to one value in the `values' array,
//     * and defines when the value should be used in the animation function.
//     * Each value in the array is a floating point number in the range
//     * [0,1]. */
//
//    @property(nullable, copy) NSArray<NSNumber *> *keyTimes;
//
//    /* An optional array of CAMediaTimingFunction objects. If the `values' array
//     * defines n keyframes, there should be n-1 objects in the
//     * `timingFunctions' array. Each function describes the pacing of one
//     * keyframe to keyframe segment. */
//
//    @property(nullable, copy) NSArray<CAMediaTimingFunction *> *timingFunctions;
//
//    /* The "calculation mode". Possible values are `discrete', `linear',
//     * `paced', `cubic' and `cubicPaced'. Defaults to `linear'. When set to
//     * `paced' or `cubicPaced' the `keyTimes' and `timingFunctions'
//     * properties of the animation are ignored and calculated implicitly. */
//
//    @property(copy) NSString *calculationMode;
//
//    /* For animations with the cubic calculation modes, these properties
//     * provide control over the interpolation scheme. Each keyframe may
//     * have a tension, continuity and bias value associated with it, each
//     * in the range [-1, 1] (this defines a Kochanek-Bartels spline, see
//     * http://en.wikipedia.org/wiki/Kochanek-Bartels_spline).
//     *
//     * The tension value controls the "tightness" of the curve (positive
//     * values are tighter, negative values are rounder). The continuity
//     * value controls how segments are joined (positive values give sharp
//     * corners, negative values give inverted corners). The bias value
//     * defines where the curve occurs (positive values move the curve before
//     * the control point, negative values move it after the control point).
//     *
//     * The first value in each array defines the behavior of the tangent to
//     * the first control point, the second value controls the second
//     * point's tangents, and so on. Any unspecified values default to zero
//     * (giving a Catmull-Rom spline if all are unspecified). */
//
//    @property(nullable, copy) NSArray<NSNumber *> *tensionValues;
//    @property(nullable, copy) NSArray<NSNumber *> *continuityValues;
//    @property(nullable, copy) NSArray<NSNumber *> *biasValues;
//
//    /* Defines whether or objects animating along paths rotate to match the
//     * path tangent. Possible values are `auto' and `autoReverse'. Defaults
//     * to nil. The effect of setting this property to a non-nil value when
//     * no path object is supplied is undefined. `autoReverse' rotates to
//     * match the tangent plus 180 degrees. */
//
//    @property(nullable, copy) NSString *rotationMode;

    
}

class AnimationDelegate :NSObject, CAAnimationDelegate {
    
    typealias OnComplete = @convention(block) (Bool) -> Void
    typealias OnDidStart = @convention(block) () -> Void

    var onStoped: OnComplete?
    var onDidStart:OnDidStart?
    init(_ onStoped:@escaping @convention(block) (Bool) -> Void) {
        self.onStoped = onStoped
    }
    init(_ onDidStart:@escaping @convention(block) () -> Void) {
        self.onDidStart = onDidStart
    }
    
    public func animationDidStart(_ anim: CAAnimation) {
        onDidStart?()
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        onStoped?(flag)
    }
}
