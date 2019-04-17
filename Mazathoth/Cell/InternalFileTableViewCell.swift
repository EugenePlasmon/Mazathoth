//
//  InternalFileCellTableViewCell.swift
//  Mazathoth
//
//  Created by Nadezhda on 12/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var internalFileLabel: UILabel?
    
    func setEmptyDirectoryCell() {
        self.internalFileLabel?.text = "No files found"
    }
}
