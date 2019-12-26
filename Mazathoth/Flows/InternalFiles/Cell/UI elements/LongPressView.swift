//
//  LongPressView.swift
//  Mazathoth
//
//  Created by Nadezhda on 13.01.2020.
//  Copyright © 2020 plasmon. All rights reserved.
//

import UIKit

final class LongPressView: UIView {

    private var path: UIBezierPath?
    
    // MARK: - Init
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.createShape()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func draw(_ rect: CGRect) {
        self.createShape()
        UIColor.brandLightBlue.setFill()
        path?.fill()
    }
    
    // MARK: - Private
    
    private func createShape() {
        self.path = UIBezierPath()
        let height = self.frame.size.height
        let width = self.frame.size.width
        self.path?.move(to: CGPoint(x: height/2, y: 0.0))
        self.path?.addArc(withCenter: CGPoint(x: height/2, y: height/2), radius: height/2, startAngle: CGFloat(270.0).toRadians(), endAngle: CGFloat(90.0).toRadians(), clockwise: false)
        self.path?.addLine(to: CGPoint(x: width, y: height))
        self.path?.addLine(to: CGPoint(x: width, y: 0.0))
        self.path?.close()
    }
}
