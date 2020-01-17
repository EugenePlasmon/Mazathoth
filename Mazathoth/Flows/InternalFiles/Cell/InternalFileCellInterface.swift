//
//  InternalFileCellInterface.swift
//  Mazathoth
//
//  Created by Nadezhda on 18/06/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

protocol InternalFileCellInterface: UICollectionViewCell {
    
    var nameLabel: UILabel { get }
    var iconImageView: UIImageView { get }
    
    var onSelectionButtonClick: ((Bool) -> Void)? { get set }
    var onCancelButtonClick: (() -> Void)? { get set }
    var onPauseButtonClick: (() -> Void)? { get set }
    var onResumeButtonClick: (() -> Void)? { get set }
    
    func setEmptyDirectoryCell(_ isTemplate: Bool)
    func configure(isDownloading: Bool, isActive: Bool)
    func configure(isEditing: Bool, isSelected: Bool)
    func configure(isLongPress: Bool)
}
