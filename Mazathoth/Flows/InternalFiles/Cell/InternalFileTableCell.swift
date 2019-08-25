//
//  InternalFileTableCell.swift
//  Mazathoth
//
//  Created by Nadezhda on 08/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFileTableCell: InternalFileCell {
    
    override func addUIElements() {
        self.addIconImageView()
        self.addNameLabel()
        self.addCancelButton()
        self.addPauseButton()
    }
    
    private func addIconImageView() {
        self.contentView.addSubview(self.iconImageView)
        NSLayoutConstraint.activate([
            self.iconImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 12.0),
            self.iconImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8.0)
            ])
        self.iconImageView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        self.iconImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
    }
    
    private func addNameLabel() {
        self.contentView.addSubview(self.name)
        NSLayoutConstraint.activate([
            self.name.leftAnchor.constraint(equalTo: self.iconImageView.rightAnchor, constant: 2.0),
            self.name.rightAnchor.constraint(lessThanOrEqualTo: self.contentView.rightAnchor, constant: -55.0),
            self.name.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20.0),
            self.name.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20.0)
            ])
    }
    
    private func addCancelButton() {
        self.contentView.addSubview(self.cancelButton)
        NSLayoutConstraint.activate([
            self.cancelButton.topAnchor.constraint(greaterThanOrEqualTo: self.name.bottomAnchor, constant: 1.0),
            self.cancelButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -2.0),
            self.cancelButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20.0),
            ])
    }
    
    private func addPauseButton() {
        self.contentView.addSubview(self.pauseOrResumeButton)
        NSLayoutConstraint.activate([
            self.pauseOrResumeButton.rightAnchor.constraint(equalTo: self.cancelButton.leftAnchor, constant: -8.0),
            self.pauseOrResumeButton.centerYAnchor.constraint(equalTo: self.cancelButton.centerYAnchor)
            ])
    }
}
