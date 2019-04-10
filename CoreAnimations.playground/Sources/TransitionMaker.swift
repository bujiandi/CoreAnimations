//
//  AnimationBisic.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/25.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import QuartzCore



public class TransitionMaker<Layer, Value> where Layer : CALayer, Value : RawRepresentable, Value.RawValue == String {
    public unowned let maker:AnimationsMaker<Layer>
    public let style:TransitionStyle
    public init(maker:AnimationsMaker<Layer>, style:TransitionStyle) {
        self.maker = maker
        self.style = style
    }
    
    @discardableResult
    public func animate(from direction:Value, duration:TimeInterval) -> AnimationTransition<Value> {
        let animation = AnimationTransition<Value>(style: style)
        animation.caAnimation.subtype = convertToOptionalCATransitionSubtype(direction.rawValue)
        animation.caAnimation.duration = duration
        animation.caAnimation.isRemovedOnCompletion = true
        maker.append(animation.caAnimation)
        return animation
    }
}

public enum TransitionNone: String {
    case none = ""
}


public enum TransitionVertical: String {
    case top    = "fromTop"
    case bottom = "fromBottom"
}

public enum TransitionHorizontal: String {
    case left   = "fromLeft"
    case right  = "fromRight"
}

public enum TransitionDirection: String {
    case none   = ""
    case left   = "fromLeft"
    case right  = "fromRight"
    case top    = "fromTop"
    case bottom = "fromBottom"
}

public enum TransitionStyle: String {
    
    case push                   // 推入效果 kCATransitionPush
    case moveIn                 // 移入效果 kCATransitionMoveIn
    case reveal                 // 截开效果 kCATransitionReveal
    case fade                   // 渐入渐出 kCATransitionFade
    
    case cube                   // 方块
    case suckEffect             // 三角
    case rippleEffect           // 水波抖动
    case pageCurl               // 上翻页
    case pageUnCurl             // 下翻页
    case oglFlip                // 上下翻转
    case cameraIrisHollowOpen   // 镜头快门开
    case cameraIrisHollowClose  // 镜头快门开
    
    // 以下API效果请慎用
    case spewEffect             // 新版面在屏幕下方中间位置被释放出来覆盖旧版面.
    case genieEffect            // 旧版面在屏幕左下方或右下方被吸走, 显示下面的新版面
    case unGenieEffect          // 新版面在屏幕左下方或右下方被释放出来覆盖旧版面.
    case twist                  // 版面以水平方向像龙卷风式转出来.
    case tubey                  // 版面垂直附有弹性的转出来.
    case swirl                  // 旧版面360度旋转并淡出, 显示出新版面.
    case charminUltra           // 旧版面淡出并显示新版面.
    case zoomyIn                // 新版面由小放大走到前面, 旧版面放大由前面消失.
    case zoomyOut               // 新版面屏幕外面缩放出现, 旧版面缩小消失.
    case oglApplicationSuspend  // 像按 ”home” 按钮的效果.
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalCATransitionSubtype(_ input: String?) -> CATransitionSubtype? {
	guard let input = input else { return nil }
	return CATransitionSubtype(rawValue: input)
}
