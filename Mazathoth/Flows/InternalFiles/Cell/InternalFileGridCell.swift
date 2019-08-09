//
//  InternalFileGridCell.swift
//  Mazathoth
//
//  Created by Nadezhda on 18/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFileGridCell: InternalFileCell {
    
    override func addIconImageView() {
        self.contentView.addSubview(self.iconImageView)
        NSLayoutConstraint.activate([
            self.iconImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.iconImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8.0),
            self.iconImageView.rightAnchor.constraint(lessThanOrEqualTo: self.contentView.rightAnchor, constant: -8.0),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 50.0),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
            ])
    }
    
    override func addNameLabel() {
        self.contentView.addSubview(self.name)
        NSLayoutConstraint.activate([
            self.name.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 8.0),
            self.name.leftAnchor.constraint(greaterThanOrEqualTo: self.contentView.leftAnchor, constant: 8.0),
            self.name.rightAnchor.constraint(lessThanOrEqualTo: self.contentView.rightAnchor, constant: -8.0),
            self.name.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -8.0),
            self.name.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
            ])
    }
}
