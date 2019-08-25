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
    
    var onClickOfDelButton: (() -> Void)? { get set }
    var onClickOfCancelButton: (() -> Void)? { get set }
    var onClickOfPauseButton: (() -> Void)? { get set }
    var onClickOfResumeButton: (() -> Void)? { get set }
    
    func setEmptyDirectoryCell()
    func configure(isDownloading: Bool, isActive: Bool)
    func configure(isEditing: Bool)
}
