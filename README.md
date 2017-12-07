# CoreAnimations
iOS 核心动画便捷使用封装
iOS 动画大多是用`UIView`, 复杂一些的需要用到核心动画，但完全不同风格的使用方式， 和复杂的调用流程实在让萌新头疼。

前几天用需要做动画, 用`Swift` 扩展了核心动画的库, 用起来舒服多了.

不自吹了先看代码:

```
view.layer.animate(forKey: "cornerRadius") {
    $0.cornerRadius
        .value(from: 0, to: cornerValue, duration: animDuration)
    $0.size
        .value(from: startRect.size, to: endRect.size, duration: animDuration)
    $0.position
        .value(from: startRect.center, to: endRect.center, duration: animDuration)
    $0.shadowOpacity
        .value(from: 0, to: 0.8, duration: animDuration)
    $0.shadowColor
        .value(from: .blackClean, to: color, duration: animDuration)
    $0.timingFunction(.easeOut).onStoped {
        [weak self] (finished:Bool) in
        if finished { self?.updateAnimations() }
    }
}
```

上面的代码中将一个视图的圆角, 尺寸, 位置, 阴影和阴影颜色都进行了动画, 并统一设置变化模式为easeOut, 当动画整体结束时调用另一个方法

```
            shareLayer.animate(forKey: "state") {
                $0.strokeStart
                    .value(from: 0, to: 1, duration: 1).delay(0.5)
                $0.strokeEnd
                    .value(from: 0, to: 1, duration: 1)
                $0.timingFunction(.easeInOut)
                $0.repeat(count: .greatestFiniteMagnitude)
            }
```

形状 `CAShareLayer` (实际为圆)的 圆形进度条动画，效果如下

![圆形进度动画.gif](http://upload-images.jianshu.io/upload_images/6192359-fc889ba3d20a0851.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

那么，这些是如何实现的呢？

首先，肯定是扩展`CALayer`，添加`animate`方法, 这里闭包传给使用者一个`AnimationsMaker`动画构造器 泛型给当前CALayer的实际类型(因为`Layer` 可能是 `CATextLayer`, `CAShareLayer`, `CAGradientLayer` ...等等 他们都继承自CALayer)

这样我们就可以精确的给构造器添加可以动画的属性, 不能动画的属性则 `.` 不出来.
```
extension CALayer {
    public func animate(forKey key:String? = nil, by makerFunc:(AnimationsMaker<Self>) -> Void) {
    }
}
```

想法是好的, 遗憾的是失败了.

xcode提示 `Self` 只能用作返回值 或者协议中，难道就没办法解决了吗？ 

答案是有的

`CALayer` 继承自 `CAMediaTiming` 协议，那么我们只需要扩展这个协议， 并加上必须继承自`CALayer` 的条件, 效果和直接扩展CALayer一样.

```
extension CAMediaTiming where Self : CALayer {
    public func animate(forKey key:String? = nil, by makerFunc:(AnimationsMaker<Self>) -> Void) {
    }
}
```

OK 效果完美, 圆满成功, 但如果一个class 没实现xxx协议怎么办? 这一招还有效么? 

答案是有的

写一个空协议, 扩展目标class 实现此协议, 再扩展空协议, 条件是必须继承自此class , 然后添加方法。

一不小心跑题了，下一步要创建动画构造器

```
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
```

目的很明显, 就是建立一个核心动画的组, 以方便于将后面一堆属性动画合并成一个

下面开始完善之前的方法

```
extension CAMediaTiming where Self : CALayer {
    
    /// CALayer 创建动画构造器
    public func animate(forKey key:String? = nil, by makerFunc:(AnimationsMaker<Self>) -> Void) {
        
        // 移除同 key 的未执行完的动画
        if let idefiniter = key {
            removeAnimation(forKey: idefiniter)
        }
        // 创建动画构造器 并 开始构造动画
        let maker = AnimationsMaker<Self>(layer: self)
        makerFunc(maker)
        
        // 如果只有一个属性做了动画, 则忽略动画组
        if maker.animations.count == 1 {
            return add(maker.animations.first!, forKey: key)
        }
        
        // 创建动画组
        let group = maker.caAnimation
        group.animations = maker.animations
        // 如果未设定动画时间, 则采用所有动画中最长的时间做动画时间
        group.duration = maker._duration ?? maker.animations.reduce(0) { max($0, $1.duration + $1.beginTime) }
    
        // 开始执行动画
        add(group, forKey: key)
    }
}
```

接下来自然是给 动画构造器 添加`CALayer`各种可动画的属性

```
extension AnimationsMaker {

    /// 对 cornerRadius 属性进行动画 默认 0
    public var cornerRadius:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"cornerRadius")
    }
    
    /// 对 bounds 属性进行动画.
    public var bounds:AnimationMaker<Layer, CGRect> {
        return AnimationMaker<Layer, CGRect>(maker:self, keyPath:"bounds")
    }
    
    /// 对 size 属性进行动画
    public var size:AnimationMaker<Layer, CGSize> {
        return AnimationMaker<Layer, CGSize>(maker:self, keyPath:"bounds.size")
    }

    /// 以下若干属性略
    ......
}
```

这里的`AnimationMaker` 和 前面的 `AnimationsMaker` 很像，但其意义是单一属性的动画构造器

`CABasicAnimation` 里面的`fromValue` 和`toValue` 的属性都是`Any?` 

原因是对layer的不同属性进行动画时, 给的值类型也是不确定的, 比如`size`属性 是`CGSize`, `position`属性是`CGPoint`, `zPosition`属性是CGFloat等, 因此它也只能是`Any?`。

但这不符合Swift 安全语言的目标, 因为我们使用时可能不小心传递了一个错误的类型给它而不被编译器发现, 增加了DEBUG的时间, 不利于生产效率

因此, 在定义 `AnimationMaker`(单一属性动画)时，应使用泛型约束变化的值和动画属性值的类型相同，并且为了方便自身构造的`CAAnimation` 加到动画组中, 将`AnimationsMaker`也传递进去

```
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
```

为了避免可能存在的循环引用内存泄露, 这里将父动画组`maker` 设为不增加引用计数的 `unowned` (相当于`OC` 的 `assign`)

虽然实际上没循环引用, 但因为都是临时变量, 没必要增加引用计数, 可以加快运行效率

`AnimationMaker`里只给了动画必要的基础属性, 一些额外属性可以通过链式语法额外设置, 所以返回了一个包装`CAAnimation` 的 `Animation` 对象, 同样传递值类型的泛型

```
public final class Animation<T, Value> : AnimationBasic<T, Value> where T : CAAnimation {
    
    /* The basic duration of the object. Defaults to 0. */
    @discardableResult
    public func duration(_ value:CFTimeInterval) -> Self {
        caAnimation.duration = value
        return self
    }
    
}
```

因为`CAAnimation`动画 和`CAAnimationGroup`动画组都共有一些属性, 所以写了一个 基类 `AnimationBasic` 而动画组的时间额外处理, 默认不给的时候使用所有动画中最大的那个时间, 否则使用强制指定的时间，参考前面的`AnimationsMaker` 定义

```
open class AnimationBasic<T, Value> where T : CAAnimation {
    
    open let caAnimation:T
    
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
        caAnimation.fillMode = mode.rawValue
        return self
    }
}
```

接下来开始锦上添花 给单一属性动画 添加快速创建

```
extension AnimationMaker {
    
    /// 创建 指定变化值的帧动画 并执行 duration 秒的弹性动画
    @discardableResult
    public func values(_ values:[Value], duration:TimeInterval) -> Animation<CAKeyframeAnimation, Value> {
        return animate(duration: duration, values: values)
    }
    
    /// 创建从 begin 到 over 并执行 duration 秒的弹性动画
    @available(iOS 9.0, *)
    @discardableResult
    public func value(from begin:Value, to over:Value, damping:CGFloat, duration:TimeInterval) -> Animation<CASpringAnimation, Value> {
        return animate(duration: duration, damping:damping, from: begin, to: over)
    }

    /// 创建从 begin 到 over 并执行 duration 秒的动画
    @discardableResult
    public func value(from begin:Value, to over:Value, duration:TimeInterval) -> Animation<CABasicAnimation, Value> {
        return animate(duration: duration, from: begin, to: over)
    }
    
    /// 创建从 当前已动画到的值 更新到 over 并执行 duration 秒的动画
    @discardableResult
    public func value(to over:Value, duration:TimeInterval) -> Animation<CABasicAnimation, Value> {
        let begin = maker.layer.presentation()?.value(forKeyPath: keyPath) ?? maker.layer.value(forKeyPath: keyPath)
        return animate(duration: duration, from: begin, to: over)
    }
}
```


给不同的核心动画添加其独有属性

```
extension Animation where T : CABasicAnimation {

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
```

```
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
```

还有一些略

最后, 给一些特殊属性, 可以点出子属性的做一些扩展添加

```
extension AnimationMaker where Value == CGSize {
    
    /// 对 size 的 width 属性进行动画
    public var width:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).width")
    }
    
    /// 对 size 的 height 属性进行动画
    public var height:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).height")
    }
}
```

```
extension AnimationMaker where Value == CATransform3D {
    
    /// 对 point 的 translation 属性进行动画
    public var translation:UnknowMaker<Layer, CGAffineTransform> {
        return UnknowMaker<Layer, CGAffineTransform>(maker:maker, keyPath:"\(keyPath).translation")
    }
    
    /// 对 point 的 rotation 属性进行动画
    public var rotation:UnknowMaker<Layer, CGAffineTransform> {
        return UnknowMaker<Layer, CGAffineTransform>(maker:maker, keyPath:"\(keyPath).rotation")
    }
    
}
```

```
extension UnknowMaker where Value == CGAffineTransform {
    /// 对 transform 的 x 属性进行动画
    public var x:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).x")
    }
    
    /// 对 transform 的 y 属性进行动画
    public var y:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).y")
    }
    
    /// 对 transform 的 z 属性进行动画
    public var z:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).z")
    }
}
```

暂时没有深入了解 `transform` 更多属性的动画, 因此只写了几个已知的基础属性, 为了避免中间使用异常, 所以弄了个 `UnknowMaker` 对此熟悉的大佬可以帮忙补充。

最后扩展了2个常用范例

```
private let kShakeAnimation:String = "shakeAnimation"
private let kShockAnimation:String = "shockAnimation"


extension CALayer {
    
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
```


最后为了方便使用, 减少编译时间, 将项目写成了一个库, iOS 和 Mac 都可以用, 因为Swift 4 仍然没有文档的库, 建议将库拖入项目 使用

![WX20171207-105559@2x.png](http://upload-images.jianshu.io/upload_images/6192359-f174a9fdf39b8a57.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

记的不仅仅是`Linked Frameworks` 自定义的framework 都要加入 `Embedded Binaries`


如果好用请给我个Start, 本文为作者原创, 如需转载, 请注明出处和原文链接。
