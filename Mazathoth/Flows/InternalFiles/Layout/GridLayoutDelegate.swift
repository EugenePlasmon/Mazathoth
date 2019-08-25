//
//  GridLayoutDelegate.swift
//  Mazathoth
//
//  Created by Nadezhda on 08/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class GridLayoutDelegate: NSObject, CustomFlowLayoutDelegate {
    
    var onSelectItem: ((_ indexPath: IndexPath) -> Void)?
    private let sectionInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    private let amountOfItems: CGFloat = 3
    private let itemSpacing: CGFloat = 2
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectItem?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sumItemSpacing = sectionInsets.left + sectionInsets.right + itemSpacing * (amountOfItems - 1)
        let sumWidthItems = collectionView.bounds.width - sumItemSpacing
        let widthItem = sumWidthItems / amountOfItems
        return CGSize(width: widthItem, height: widthItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
}
