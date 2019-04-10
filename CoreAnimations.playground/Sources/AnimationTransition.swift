//
//  AnimationBisic.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/25.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import QuartzCore

open class AnimationTransition<Value> : AnimationBasic<CATransition, Value> where Value : RawRepresentable, Value.RawValue == String {
    
    public init(style:TransitionStyle) {
        let transition = CATransition()
        transition.type = convertToCATransitionType(style.rawValue)
        super.init(transition)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATransitionType(_ input: String) -> CATransitionType {
	return CATransitionType(rawValue: input)
}
