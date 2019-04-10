//
//  GraphicsOperator.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/26.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import CoreGraphics

extension CGPoint  {
    public static func +(lhs:CGPoint, rhs:CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func -(lhs:CGPoint, rhs:CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func *(lhs:CGPoint, rhs:CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    public static func /(lhs:CGPoint, rhs:CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
}

extension CGRect {
    public var center:CGPoint {
        return CGPoint(x: width / 2 + minX, y: height / 2 + minY)
    }
}

extension CGPoint {
    public func angle(with point:CGPoint) -> CGFloat {
        let width  = point.x - x
        let height = y - point.y
        let radian = atan( height / width )
        var result = 180.0 * radian / .pi
        if width >= 0 {
            result += 180.0
        } else if height >= 0 {
            result += 360.0
        }
        return result
    }
    
    public func distance(to point:CGPoint) -> CGFloat {
        let dx = abs(point.x - x)
        let dy = abs(point.y - y)
        return sqrt(dx * dx + dy * dy)
    }
    
    public func point(byAngle angle:CGFloat, andRadius radius:CGFloat) -> CGPoint {
        let radian = angle * .pi / 180
        let dx = radius * cos(radian)
        let dy = radius * sin(radian)
        return CGPoint(x: self.x + dx, y: self.y - dy)
    }
    
    /// 塞贝尔曲线
    public func quadCurve(to point:CGPoint, control:(CGPoint, CGPoint) -> CGPoint) -> CGPath {
        let path = CGMutablePath()
        path.move(to: self)
        path.addQuadCurve(to: point, control: control(self, point))
        return path
    }
}
