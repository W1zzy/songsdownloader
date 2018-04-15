//
//  ProgressView.swift
//  songdownloader
//
//  Created by Антон Братчик on 14.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    var progress: Float = 0.0 {
        willSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.strokeEnd = CGFloat(newValue)
            CATransaction.commit()
        }
    }
    
    private let progressLayer  : CAShapeLayer = CAShapeLayer()
    override func draw(_ rect: CGRect) {
        let startAngle = CGFloat.pi / 2.0
        let endAngle = CGFloat.pi * 2 + CGFloat.pi / 2
        let centerPoint = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        
        progressLayer.path = UIBezierPath(arcCenter:centerPoint, radius: rect.width / 2.0 - 10.0, startAngle:startAngle, endAngle:endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = #colorLiteral(red: 0.8092500567, green: 0.008618571796, blue: 0.107035704, alpha: 1)
        progressLayer.lineWidth = 2.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.strokeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        backgroundLayer.fillColor = nil
        backgroundLayer.lineWidth = 2.0
        backgroundLayer.path = progressLayer.path
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
    }
}
