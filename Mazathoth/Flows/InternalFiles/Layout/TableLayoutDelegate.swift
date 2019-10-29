//
//  TableLayoutDelegate.swift
//  Mazathoth
//
//  Created by Nadezhda on 08/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//


import UIKit

final class TableLayoutDelegate: NSObject, CustomFlowLayoutDelegate {
    
    var onSelectItem: ((_ indexPath: IndexPath) -> Void)?
    var onStartScrolling: ((_ scrollView: UIScrollView) -> Void)?
    var onStopScrolling: (() -> Void)?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onSelectItem?(indexPath)
    }
    
    // MARK: - Style
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 2.0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    // MARK: - Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.onStartScrolling?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.onStopScrolling?()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.onStopScrolling?()
        }
    }
}
