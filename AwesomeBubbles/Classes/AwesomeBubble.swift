//
//  AwesomeBubble.swift
//  Pods
//
//  Created by xi zhang on 9/26/17.
//
//

import UIKit

open class AwesomeBubble: UIView {
    internal var tapGestureRecognizer: UITapGestureRecognizer?
    public var currentSize: Int = 1
    
    open override var frame: CGRect {
        didSet {
            clipsToBounds = true
            setNeedsDisplay()
        }
    }
    
    public var contentColor: UIColor = UIColor.clear
    public var borderColor: UIColor = UIColor.black
    
    open override func draw(_ rect: CGRect) {
        let circleRect = rect.insetBy(dx: 1, dy: 1)
        let path = UIBezierPath(ovalIn: circleRect)
        contentColor.setFill()
        borderColor.setStroke()
        path.fill()
        path.stroke()
    }
    
    @available(iOS 9.0, *)
    open override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}
