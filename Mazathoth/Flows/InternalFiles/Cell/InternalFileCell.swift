//
//  InternalFileCell.swift
//  Mazathoth
//
//  Created by Nadezhda on 23/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class InternalFileCell: UICollectionViewCell, InternalFileCellInterface {
    
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
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private(set) var delButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "deleteIcon"), for: .normal)
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureUI()
    }
    
    func setEmptyDirectoryCell() {
        self.iconImageView.image = nil
        self.name.text = "No files found"
    }
    
    // MARK: - UI
    
    private func configureUI() {
        self.backgroundColor = .white
        self.addIconImageView()
        self.addNameLabel()
        self.addDelButton()
    }
    
    func addIconImageView() {
        self.contentView.addSubview(self.iconImageView)
    }
    
    func addNameLabel() {
        self.contentView.addSubview(self.name)
    }
    
    private func addDelButton() {
        self.contentView.addSubview(self.delButton)
        NSLayoutConstraint.activate([
            self.delButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.delButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8.0),
            self.delButton.widthAnchor.constraint(equalToConstant: 20.0),
            self.delButton.heightAnchor.constraint(equalToConstant: 20.0)
            ])
    }
}
