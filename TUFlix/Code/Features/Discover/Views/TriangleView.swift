//
//  TriangleView.swift
//  TUFlix
//
//  Created by Oliver Krakora on 16.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

@IBDesignable
class TriangleView: UIView {
    
    @IBInspectable
    var fillColor: UIColor = Asset.primaryColor.color
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        UIColor.clear.setFill()
        context?.fill(rect)
        
        let path = UIBezierPath()
        UIColor.clear.setStroke()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.close()
        
        fillColor.setFill()
        path.fill()
        path.stroke()
    }
    
}
