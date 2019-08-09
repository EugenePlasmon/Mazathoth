//
//  InternalFileCellInterface.swift
//  Mazathoth
//
//  Created by Nadezhda on 18/06/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

protocol InternalFileCellInterface: UICollectionViewCell {
    
    var name: UILabel { get }
    var iconImageView: UIImageView { get }
    var delButton: UIButton { get }
    
    func setEmptyDirectoryCell()
}
