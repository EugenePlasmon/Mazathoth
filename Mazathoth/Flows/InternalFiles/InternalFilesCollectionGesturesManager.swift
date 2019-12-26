//
//  InternalFilesCollectionGesturesManager.swift
//  Mazathoth
//
//  Created by Nadezhda on 23/10/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesCollectionGesturesManager {
    
    typealias OnBeginGestureClosure = () -> Void
    typealias OnEndGestureClosure = (_ initialIndexPath: IndexPath, _ indexPath: IndexPath) -> Void
    var onBeginGesture: OnBeginGestureClosure?
    var onEndGesture: OnEndGestureClosure?
    
    private let longPress: UILongPressGestureRecognizer
    private let collectionView: UICollectionView
    private let internalFiles: [FileSystemEntity]
    
    private var location: CGPoint?
    private var diff: (x: CGFloat, y: CGFloat) = (x: 0, y: 0)
    private var cellDetail: CellDetail?
    private var lastIndexPath: IndexPath?
    
    private struct CellDetail {
        var snapshot: UIView?
        var initialIndexPath: IndexPath?
    }
    
    // MARK: - Init
    
    init(_ longPress: UILongPressGestureRecognizer, for collectionView: UICollectionView, internalFiles: [FileSystemEntity]) {
        self.longPress = longPress
        self.collectionView = collectionView
        self.internalFiles = internalFiles
    }
    
    // MARK: - Internal
    
    func enableGesture() {
        let state = longPress.state
        let location = longPress.location(in: collectionView)
        self.location = location
        let locationWithDiff = CGPoint(x: location.x - diff.x, y: location.y - diff.y)
        let indexPathStart = collectionView.indexPathForItem(at: location)
        let indexPath = collectionView.indexPathForItem(at: locationWithDiff)
        
        switch state {
        case .began:
            guard !self.internalFiles.isEmpty else { return }
            self.onBeginGesture?()
            self.configureSelectedCell(indexPathStart, isLongPress: true)
            self.addCellSnapshot(indexPathStart)
        case .changed:
            self.moveCellSnapshot()
            guard let indexPath = indexPath, (self.internalFiles[safe: (indexPath.row)] as? Folder) != nil  else {
                self.setDefaultCellColor(for: collectionView)
                return
            }
            self.changeCellColor(indexPath, for: collectionView)
        case .ended:
            self.configureSelectedCell(self.cellDetail?.initialIndexPath, isLongPress: false)
            self.moveInternalFile(indexPath, for: collectionView)
        case .cancelled:
            self.cancelCellAction(indexPath, for: collectionView)
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Private
    
    private func addCellSnapshot(_ indexPath: IndexPath?) {
        guard let indexPath = indexPath,
            let location = self.location,
            !self.internalFiles[indexPath.row].isDownloading,
            let cellSnapshot = self.cellSnapshot(indexPath, for: collectionView) else {
            return
        }
        self.diff.x = location.x - cellSnapshot.center.x
        self.diff.y = location.y - cellSnapshot.center.y
        collectionView.addSubview(cellSnapshot)
    }

    private func cellSnapshot(_ indexPath: IndexPath, for collectionView: UICollectionView) -> UIView? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InternalFileCellInterface else {
            return nil
        }
        self.cellDetail = CellDetail()
        self.cellDetail?.initialIndexPath = indexPath
        self.cellDetail?.snapshot = cell.snapshot
        guard let cellSnapshot = self.cellDetail?.snapshot else {
            return nil
        }
        cellSnapshot.center = cell.center
        cell.isHidden = true
        return cellSnapshot
    }
    
    private func removeSnapshot() {
        self.cellDetail?.snapshot?.removeFromSuperview()
        self.cellDetail = nil
        self.diff.x = 0
        self.diff.y = 0
    }
    
    private func moveCellSnapshot() {
        guard let location = self.location, let cellSnapshot = self.cellDetail?.snapshot else {
            return
        }
        cellSnapshot.center.y = location.y - diff.y
        cellSnapshot.center.x = location.x - diff.x
    }
    
    private func moveInternalFile(_ indexPath: IndexPath?, for collectionView: UICollectionView) {
        guard let initialIndexPath = self.cellDetail?.initialIndexPath,
            let cell = collectionView.cellForItem(at: initialIndexPath) as? InternalFileCellInterface,
            !self.internalFiles.isEmpty else {
                return
        }
        if indexPath != initialIndexPath, indexPath?.row != nil,
            let indexPath = indexPath, (self.internalFiles[safe: indexPath.row] as? Folder) != nil {
            self.onEndGesture?(initialIndexPath, indexPath)
            cell.alpha = 0
            collectionView.deleteItems(at: [initialIndexPath])
        } else {
            self.cellDetail?.snapshot?.center = cell.center
        }
        cell.isHidden = false
        self.setDefaultCellColor(for: collectionView)
        self.removeSnapshot()
    }
    
    private func changeCellColor(_ indexPath: IndexPath, for collectionView: UICollectionView) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InternalFileCellInterface else {
            return
        }
        cell.backgroundColor = .lightGray
        guard self.lastIndexPath != indexPath else {
            return
        }
        if self.lastIndexPath != nil {
            self.setDefaultCellColor(for: collectionView)
            self.lastIndexPath = nil
        } else {
            self.lastIndexPath = indexPath
        }
    }
    
    private func setDefaultCellColor(for collectionView: UICollectionView) {
        for row in 0..<self.internalFiles.count {
            guard let cell = collectionView.cellForItem(at: [0, row]) as? InternalFileCellInterface else {
                return
            }
            cell.configure(isDownloading: self.internalFiles[row].isDownloading, isActive: self.internalFiles[row].isDownloadActive)
        }
    }
    
    private func cancelCellAction(_ indexPath: IndexPath?, for collectionView: UICollectionView) {
        guard let indexPath = indexPath, let cell = collectionView.cellForItem(at: indexPath) as? InternalFileCellInterface else {
            return
        }
        cell.isHidden = false
        self.setDefaultCellColor(for: collectionView)
        self.removeSnapshot()
    }
    
    private func configureSelectedCell(_ indexPath: IndexPath?, isLongPress: Bool) {
        guard let indexPath = indexPath,
            let cell = collectionView.cellForItem(at: indexPath) as? InternalFileCellInterface else {
                return
        }
        cell.configure(isLongPress: isLongPress)
    }
}

