//
//  VCTextLayer.swift
//  CoreAnimations
//
//  Created by 慧趣小歪 on 2017/12/1.
//

import QuartzCore

open class CVTextLayer : CATextLayer {
    
    open override func draw(in ctx: CGContext) {
        let height = bounds.height
        let fontSize = self.fontSize
        let yDiff = (height - fontSize) / 2 //- fontSize / 10
        
        ctx.saveGState()
        ctx.ctm.translatedBy(x: 0.0, y: -yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}
