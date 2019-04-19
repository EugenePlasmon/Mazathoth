//
//  InternalFileCell.swift
//  Mazathoth
//
//  Created by Nadezhda on 18/06/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFileCell: UITableViewCell {
    
    private(set) var name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.numberOfLines = 0
        return label
    }()
    
    private(set) var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureUI()
    }
    
    func setEmptyDirectoryCell() {
        self.name.text = "No files found"
    }
    
    // MARK: - UI
    
    private func configureUI() {
        self.addIconImageView()
        self.addNameLabel()
    }
    
    private func addNameLabel() {
        self.contentView.addSubview(self.name)
        NSLayoutConstraint.activate([
            self.name.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.name.leftAnchor.constraint(equalTo: self.iconImageView.rightAnchor, constant: 8.0),
            self.name.rightAnchor.constraint(lessThanOrEqualTo: self.contentView.rightAnchor, constant: -40),
            self.name.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
    }
    
    private func addIconImageView() {
        self.contentView.addSubview(self.iconImageView)
        NSLayoutConstraint.activate([
            self.iconImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.iconImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 12.0),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            ])
    }
}
