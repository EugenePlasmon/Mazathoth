//
//  CustomFlowLayoutDelegate.swift
//  Mazathoth
//
//  Created by Nadezhda on 08/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

protocol CustomFlowLayoutDelegate: class, UICollectionViewDelegateFlowLayout {
    var didSelectItem: ((_ indexPath: IndexPath) -> Void)? { get set }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}
