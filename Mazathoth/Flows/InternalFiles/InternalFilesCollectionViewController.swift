//
//  InternalFilesCollectionViewController.swift
//  Mazathoth
//
//  Created by Nadezhda on 04/10/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesCollectionViewController: UICollectionViewController {
    
    var internalFiles: [FileSystemEntity] = []
    var style: InternalFilesViewController.Style = .table {
        didSet { self.updatePresentationStyle() }
    }
    private let internalFilesManager: InternalFilesManagerInterface
    private var delegate: CustomFlowLayoutDelegate?
    private var isEditingMode: Bool = false
    private var diff: (x: CGFloat, y: CGFloat) = (x: 0, y: 0)
    private var cellDetail: CellDetail?
    private var lastIndexPath: IndexPath?
    
    var onLongPressOnCell: (() -> Void)?
    var onClickOfCancelButton: ((URL) -> Void)?
    var onClickOfPauseButton: ((URL) -> Void)?
    var onClickOfResumeButton: ((URL, String) -> Void)?
    
    private struct CellDetail {
        var snapshot: UIView?
        var initialIndexPath: IndexPath?
    }
    
    // MARK: - Init
    
    init(internalFilesManager: InternalFilesManagerInterface) {
        self.internalFilesManager = internalFilesManager
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerItem()
        self.configureUI()
        self.addGesture()
    }
    
    private func registerItem() {
        self.collectionView.register(InternalFileTableCell.self, forCellWithReuseIdentifier: String(describing: InternalFileTableCell.self))
        self.collectionView.register(InternalFileGridCell.self, forCellWithReuseIdentifier: String(describing: InternalFileGridCell.self))
    }
    
    // MARK: - UI
    
    private func configureUI() {
        self.collectionView.backgroundColor = .white
        self.updatePresentationStyle()
    }
    
    private func updatePresentationStyle() {
        switch style {
        case .table:
            delegate = TableLayoutDelegate()
            self.selectItem()
        case .grid:
            delegate = GridLayoutDelegate()
            self.selectItem()
        }
        self.collectionView.delegate = delegate
        self.collectionView.reloadData()
    }
    
    // MARK: - Delegate
    
    func selectItem() {
        guard let delegate = self.delegate else { return }
        delegate.onSelectItem = { indexPath in
            guard !self.internalFiles.isEmpty ,!self.internalFiles[indexPath.row].isDownloading else { return }
            self.selectItem(indexPath: indexPath)
        }
    }
    
    func selectItem(indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let selectedFile = self.internalFiles[safe: indexPath.row] else {
            return
        }
        // TODO: - нормальный роутинг
        guard (selectedFile as? Folder) != nil else {
            guard selectedFile.name.pathExtension == "mp3" else { return }
            let audioPlayerVC = AudioPlayerViewController(file: selectedFile)
            self.navigationController?.pushViewController(audioPlayerVC, animated: true)
            return
        }
        let internalFilesModuleBuilder = InternalFilesModuleBuilder()
        let internalFilesViewController = internalFilesModuleBuilder.build(path: selectedFile.absolutePath)
        internalFilesViewController.documentsDirectoryPath = selectedFile.absolutePath
        internalFilesViewController.style = self.style
        self.navigationController?.pushViewController(internalFilesViewController, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(self.internalFiles.count, 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell: UICollectionViewCell
        switch style {
        case .table:
            dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: InternalFileTableCell.self), for: indexPath)
        case .grid:
            dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: InternalFileGridCell.self), for: indexPath)
        }
        guard let cell = dequeuedCell as? InternalFileCellInterface else {
            assertionFailure("Unexpected cell type: \(type(of: dequeuedCell))")
            return dequeuedCell
        }
        guard !self.internalFiles.isEmpty else {
            cell.setEmptyDirectoryCell()
            cell.configure(isDownloading: false, isActive: false)
            cell.configure(isEditing: false)
            return cell
        }
        cell.name.text = self.internalFiles[indexPath.row].name
        cell.configure(isEditing: isEditingMode)
        cell.configure(isDownloading: self.internalFiles[indexPath.row].isDownloading, isActive: self.internalFiles[indexPath.row].isDownloadActive)
        self.onClickButton(in: cell, whith: indexPath)
        guard (self.internalFiles[indexPath.row] as? Folder) != nil else {
            cell.iconImageView.image = nil
            cell.iconImageView.isHidden = true
            return cell
        }
        cell.iconImageView.image = UIImage(named: "Folder")
        cell.iconImageView.isHidden = false
        return cell
    }
    
    // MARK: - Touch Handlers
    
    private func onClickButton(in cell: InternalFileCellInterface, whith indexPath: IndexPath) {
        let download = self.internalFiles[indexPath.row].downloadEntity
        cell.onClickOfDelButton = { [weak self] in
            self?.delButtonTap(cell)
        }
        cell.onClickOfCancelButton = { [weak self] in
            guard let self = self, let download = download else { return }
            self.onClickOfCancelButton?(download.url)
        }
        cell.onClickOfPauseButton = { [weak self] in
            guard let self = self, let download = download else { return }
            self.onClickOfPauseButton?(download.url)
        }
        cell.onClickOfResumeButton = { [weak self] in
            guard let self = self, let download = download else { return }
            let name = self.internalFiles[indexPath.row].name
            self.onClickOfResumeButton?(download.url, name)
        }
    }
    
    // MARK: - Delete Item
    
    private func delButtonTap(_ cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        guard !self.internalFiles.isEmpty else { return }
        self.removeInternalFile(forItemAt: indexPath)
        if self.internalFiles.count == 0 {
            collectionView.reloadData()
        } else {
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    private func removeInternalFile(forItemAt indexPath: IndexPath) {
        self.internalFilesManager.removeInternalFile(atPath: self.internalFiles[indexPath.row].absolutePath)
        self.internalFiles.remove(at: indexPath.row)
    }
    
    // MARK: - Private
    
    func checkName(_ checkableName: String) -> String {
        var name = checkableName.deletingPathExtension
        var count = 0
        let names: Set<String> = Set((self.internalFiles.map { $0.name.deletingPathExtension }))
        while names.contains(name) {
            count += 1
            name = checkableName.deletingPathExtension + "-" + String(count)
        }
        return name.appendingPathExtension(checkableName.pathExtension) ?? name
    }
}

// MARK: - Gesture

extension InternalFilesCollectionViewController: UIGestureRecognizerDelegate {
    
    private func addGesture() {
        let longPressOnCell = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCellGestureRecognized(_:)))
        self.collectionView.addGestureRecognizer(longPressOnCell)
    }
    
    @objc private func longPressOnCellGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        guard let longPress = gestureRecognizer as? UILongPressGestureRecognizer else {
            return
        }
        let state = longPress.state
        let location = longPress.location(in: collectionView)
        let locationWithDiff = CGPoint(x: location.x - diff.x, y: location.y - diff.y)
        let indexPathStart = collectionView.indexPathForItem(at: location)
        let indexPath = collectionView.indexPathForItem(at: locationWithDiff)
        
        switch state {
        case .began:
            guard !self.internalFiles.isEmpty else { return }
            self.handleBeginEditing()
            guard let indexPath = indexPathStart, !self.internalFiles[indexPath.row].isDownloading else {
                return
            }
            self.cellDetail = CellDetail()
            guard let cellSnapshot = self.cellSnapshot(indexPath, for: collectionView) else {
                return
            }
            self.diff.x = location.x - cellSnapshot.center.x
            self.diff.y = location.y - cellSnapshot.center.y
            collectionView.addSubview(cellSnapshot)
        case .changed:
            guard let cellSnapshot = self.cellDetail?.snapshot else {
                return
            }
            cellSnapshot.center.y = location.y - diff.y
            cellSnapshot.center.x = location.x - diff.x
            guard let indexPath = indexPath, (self.internalFiles[safe: (indexPath.row)] as? Folder) != nil  else {
                self.setDefaultCellColor(for: collectionView)
                return
            }
            self.changeCellColor(indexPath, for: collectionView)
        case .ended:
            self.moveInternalFile(indexPath, for: collectionView)
        case .cancelled:
            self.cancelCellAction(indexPath, for: collectionView)
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    private func cellSnapshot(_ indexPath: IndexPath, for collectionView: UICollectionView) -> UIView? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InternalFileCellInterface else {
            return nil
        }
        self.cellDetail?.initialIndexPath = indexPath
        self.cellDetail?.snapshot = snapshot(for: cell)
        guard let cellSnapshot = self.cellDetail?.snapshot else {
            return nil
        }
        cellSnapshot.center = cell.center
        cell.isHidden = true
        return cellSnapshot
    }
    
    private func snapshot(for inputView: UIView) -> UIView? {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        inputView.layer.render(in: currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snapshot = UIImageView(image: image)
        return snapshot
    }
    
    private func removeSnapshot() {
        self.cellDetail?.snapshot?.removeFromSuperview()
        self.cellDetail = nil
        self.diff.x = 0
        self.diff.y = 0
    }
    
    private func moveInternalFile(_ indexPath: IndexPath?, for collectionView: UICollectionView) {
        guard let initialIndexPath = self.cellDetail?.initialIndexPath,
            let cell = collectionView.cellForItem(at: initialIndexPath) as? InternalFileCellInterface,
            !self.internalFiles.isEmpty else {
                return
        }
        if indexPath != initialIndexPath, indexPath?.row != nil,
            let indexPath = indexPath, (self.internalFiles[safe: indexPath.row] as? Folder) != nil {
            self.moveInternalFile(at: initialIndexPath, to: indexPath)
            cell.alpha = 0
            collectionView.deleteItems(at: [initialIndexPath])
        } else {
            self.cellDetail?.snapshot?.center = cell.center
        }
        cell.isHidden = false
        self.setDefaultCellColor(for: collectionView)
        self.removeSnapshot()
    }
    
    private func moveInternalFile(at initialIndexPath: IndexPath, to indexPath: IndexPath) {
        let srcPath = self.internalFiles[initialIndexPath.row].absolutePath
        var srcName = self.internalFiles[initialIndexPath.row].name
        let internalFilesModuleBuilder = InternalFilesModuleBuilder()
        let internalFilesViewController = internalFilesModuleBuilder.build(path: self.internalFiles[indexPath.row].absolutePath)
        internalFilesViewController.loadDataFromDocumentDirectory()
        srcName = internalFilesViewController.collectionViewController.checkName(srcName)
        let dstPath = self.internalFiles[indexPath.row].absolutePath.appendingPathComponent(srcName)
        self.internalFilesManager.moveInternalFile(atPath: srcPath, toPath: dstPath)
        self.internalFiles.remove(at: initialIndexPath.row)
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
    
    private func handleBeginEditing() {
        for row in 0..<self.internalFiles.count {
            guard let cell = collectionView.cellForItem(at: [0, row]) as? InternalFileCellInterface,
                !self.internalFiles[row].isDownloading else {
                    return
            }
            self.isEditingMode = true
            cell.configure(isEditing: isEditingMode)
            self.onLongPressOnCell?()
            delegate?.onSelectItem = nil
        }
    }
    
    func handleEndEditing() {
        for row in 0..<max(self.internalFiles.count, 1) {
            guard let cell = collectionView.cellForItem(at: [0, row]) as? InternalFileCellInterface else {
                return
            }
            self.isEditingMode = false
            cell.configure(isEditing: isEditingMode)
        }
        self.selectItem()
    }
}
