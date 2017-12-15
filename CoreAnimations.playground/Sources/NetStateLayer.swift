//
//  NetStateView.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/24.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import QuartzCore

public enum NetStateStyle:Int {
    case automate
    case progress
    case success
    case failure
}

open class NetStateLayer: CALayer {

    private static let color = CGColor.device(ARGB: 0xFF333333)!

    open var state:NetStateStyle = .failure {
        didSet { guard case .automate = state else { return updateAnimations() } }
    }
    open var progress:CGFloat = 0 {
        didSet {
            guard case .progress = state else { return }
            shareLayer.strokeEnd = progress
        }
    }
    
    open func successAnimate(to endRect:CGRect, withDuration animDuration:TimeInterval = 0.5) {
        let startRect = presentation()?.frame ?? frame
        let path = startRect.center.quadCurve(to: endRect.center) {
            CGPoint(x: $1.x, y: $0.y)
        }
        
        position = endRect.center
        opacity = 0
        
        shareLayer.removeAllAnimations()
        shareLayer.opacity = 0
        shareLayer.animate(forKey: "state") {
            $0.alpha.value(from: 0, to: 0, duration: animDuration)
        }
        
        removeAllAnimations()
        
        let startTransform:CATransform3D = presentation()?.transform ?? transform
        let endTransform:CATransform3D = CATransform3DMakeScale(endRect.width / startRect.width, endRect.height / startRect.height, 1)
        animate(forKey: "cornerRadius") {
            $0.alpha.value(from: 1, to: 0, duration: animDuration)
            $0.transform
                .value(from: startTransform, to: endTransform, duration: animDuration)
            $0.position
                .value(along: path, duration: animDuration)
            $0.timingFunction(.easeInOut).onStoped({
                [weak self] (finish:Bool) in
                if finish {
                    self?.removeFromSuperlayer()
                    self?.opacity = 1
                }
            })
        }
    }
    
    open func failureAnimate(to endRect:CGRect, withDuration animDuration:TimeInterval = 0.5) {
        let startRect = frame
        let cornerValue = cornerRadius
        let color = NetStateLayer.color
        
        shareLayer.removeAllAnimations()
        shareLayer.opacity = 0
        shareLayer.animate(forKey: "state") {
            $0.alpha.value(from: 0, to: 0, duration: animDuration)
        }
        
        position = endRect.center
        bounds.size = endRect.size
        cornerRadius = 0
        shadowColor = .blackClean
        shadowOpacity = 0.8
        shadowOffset = CGSize(width: 1, height: 1)
        
        removeAllAnimations()

        animate(forKey: "cornerRadius") {
            $0.cornerRadius
                .value(from: 0, to: cornerValue, duration: animDuration)
            $0.size
                .value(from: startRect.size, to: endRect.size, duration: animDuration)
            $0.position
                .value(from: startRect.center, to: endRect.center, duration: animDuration)
            $0.shadowOpacity
                .value(from: 0.8, to: 0, duration: animDuration)
            $0.shadowColor
                .value(from: color, to: .blackClean, duration: animDuration)
            $0.timingFunction(.easeInOut)
        }
    }
    
    open func startAnimate(from startRect:CGRect, to endRect:CGRect, withDuration animDuration:TimeInterval = 0.5) {
        
        let cornerValue = min(endRect.width, endRect.height) / 2
        
        let color = NetStateLayer.color
        
        shareLayer.strokeStart = 0
        shareLayer.strokeEnd = 0
        shareLayer.removeAllAnimations()
        frame = endRect
        cornerRadius = cornerValue
        shadowColor = color
        shadowOpacity = 0.8
        shadowOffset = CGSize(width: 1, height: 1)
        
        animate(forKey: "cornerRadius") {
            
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
        
    }
    
    open var progressColor:CGColor?
    
    private lazy var shareLayer:CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = progressColor ?? CGColor.device(ARGB: 0xFF009CCC)
        layer.fillColor = nil
        layer.lineWidth = 2
        layer.frame = bounds
        layer.transform = CATransform3DMakeRotation(.pi/2 * 3, 0, 0, 1)
        var transform = CGAffineTransform.identity
        let path = CGPath(roundedRect: bounds.insetBy(dx: 5, dy: 5), cornerWidth: (bounds.width - 10) / 2, cornerHeight: (bounds.height - 10) / 2, transform: &transform)
        layer.path = path
        layer.strokeStart = 0
        layer.strokeEnd = 0
//        layer.fillColor = CGColor.device(ARGB: 0xFF515151)
        addSublayer(layer)
        return layer
    }()
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        shareLayer.frame = bounds
        var transform = CGAffineTransform.identity
        let path = CGPath(roundedRect: bounds.insetBy(dx: 5, dy: 5), cornerWidth: (bounds.width - 10) / 2, cornerHeight: (bounds.height - 10) / 2, transform: &transform)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shareLayer.path = path
        CATransaction.commit()
    }
    
    open func updateAnimations() {
        let start = shareLayer.presentation()?.strokeStart ?? 0
        let end  = shareLayer.presentation()?.strokeEnd ?? 1
        var over = progress
//        var animations: [CAAnimation] = []
        shareLayer.removeAllAnimations()
        switch state {
        case .automate:
            shareLayer.strokeStart = 0
            shareLayer.strokeEnd = 1
            shareLayer.opacity = 1
            shareLayer.animate(forKey: "state") {
                $0.alpha.value(to: 1, duration: 0.2)
                $0.strokeStart
                    .value(from: 0, to: 1, duration: 1).delay(0.5)
                $0.strokeEnd
                    .value(from: 0, to: 1, duration: 1)
                $0.timingFunction(.easeInOut)
                $0.repeat(count: .greatestFiniteMagnitude)
            }
            return
        case .progress:
            over = progress
        case .success:
            over = 1
        case .failure:
            over = 0
        }
        
        shareLayer.strokeStart = 0
        shareLayer.strokeEnd = over
        shareLayer.opacity = 1
        shareLayer.animate(forKey: "state") {
            $0.alpha
                .value(to: 1, duration: 0.1)
            $0.strokeStart
                .value(from: start, to: 0, duration: Double(start) / 8)
            $0.strokeEnd
                .value(from: end, to: over, duration: Double(fabs(over - end)) / 4)
            $0.timingFunction(.easeOut)
        }
    }
    
}
