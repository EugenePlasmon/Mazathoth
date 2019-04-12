//
//  PlayPauseButton.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 14/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class PlayPauseButton: UIControl {
    
    enum Kind {
        case play
        case pause
    }
    
    var kind: Kind = .play {
        didSet {
            guard self.kind != oldValue else { return }
            self.setNeedsDisplay()
        }
    }
    
    var onTap: (() -> Void)?
    
    private struct Constants {
        // TODO: перенести в конфигурацию при ините
        static let tintColor = UIColor(white: 0.8, alpha: 1.0)
    }
    
    // MARK: - Init
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit() {
        self.backgroundColor = .clear
        self.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle
    
    override func draw(_ rect: CGRect) {
        switch self.kind {
        case .play:
            self.drawRectangle(in: rect)
        case .pause:
            self.drawPause(in: rect)
        }
    }
    
    // MARK: - Private
    
    @objc private func handleTap() {
        self.onTap?()
    }
    
    // MARK: - Drawings
    
    private func drawRectangle(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(Constants.tintColor.cgColor)
        context.beginPath()
        context.move(to: CGPoint(x: rect.maxX / 6, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX / 6, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY / 2))
        context.closePath()
        context.fillPath()
    }
    
    private func drawPause(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(Constants.tintColor.cgColor)
        context.beginPath()
        context.move(to: CGPoint(x: rect.maxX / 5, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX / 5, y: rect.maxY))
        context.addLine(to: CGPoint(x: 2 * rect.maxX / 5, y: rect.maxY))
        context.addLine(to: CGPoint(x: 2 * rect.maxX / 5, y: rect.minY))
        context.closePath()
        context.fillPath()
        context.move(to: CGPoint(x: 3 * rect.maxX / 5, y: rect.minY))
        context.addLine(to: CGPoint(x: 3 * rect.maxX / 5, y: rect.maxY))
        context.addLine(to: CGPoint(x: 4 * rect.maxX / 5, y: rect.maxY))
        context.addLine(to: CGPoint(x: 4 * rect.maxX / 5, y: rect.minY))
        context.closePath()
        context.fillPath()
    }
}
