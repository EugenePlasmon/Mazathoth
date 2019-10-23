//
//  InternalFileGridCell.swift
//  Mazathoth
//
//  Created by Nadezhda on 18/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFileGridCell: InternalFileCell {
    
    override func addUIElements() {
        self.addIconImageView()
        self.addNameLabel()
        self.addCancelButton()
        self.addPauseButton()
    }
    
    func addIconImageView() {
        self.contentView.addSubview(self.iconImageView)
        NSLayoutConstraint.activate([
            self.iconImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.iconImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8.0),
            self.iconImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8.0)
            ])
        self.iconImageView.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        self.iconImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
    }
    
    func addNameLabel() {
        self.contentView.addSubview(self.nameLabel)
        NSLayoutConstraint.activate([
            self.nameLabel.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor),
            self.nameLabel.leftAnchor.constraint(greaterThanOrEqualTo: self.contentView.leftAnchor, constant: 8.0),
            self.nameLabel.rightAnchor.constraint(lessThanOrEqualTo: self.contentView.rightAnchor, constant: -8.0),
            self.nameLabel.heightAnchor.constraint(equalToConstant: 60),
            self.nameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
            ])
    }
    
    private func addCancelButton() {
        self.contentView.addSubview(self.cancelButton)
        NSLayoutConstraint.activate([
            self.cancelButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -2.0),
            self.cancelButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8.0),
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
