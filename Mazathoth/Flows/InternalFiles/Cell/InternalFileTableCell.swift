//
//  InternalFileTableCell.swift
//  Mazathoth
//
//  Created by Nadezhda on 08/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFileTableCell: InternalFileCell {
    
    override func addIconImageView() {
        self.contentView.addSubview(self.iconImageView)
        NSLayoutConstraint.activate([
            self.iconImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.iconImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 12.0),
            self.iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -8.0),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 50.0),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
    }
    
    override func addNameLabel() {
        self.contentView.addSubview(self.name)
        NSLayoutConstraint.activate([
            self.name.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.name.leftAnchor.constraint(equalTo: self.iconImageView.rightAnchor, constant: 12.0),
            self.name.rightAnchor.constraint(lessThanOrEqualTo: self.contentView.rightAnchor, constant: -21.0),
            self.name.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            ])
    }
}
