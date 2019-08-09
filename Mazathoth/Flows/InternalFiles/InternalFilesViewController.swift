//
//  InternalFilesViewController.swift
//  Mazathoth
//
//  Created by Nadezhda on 08/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesViewController: UICollectionViewController {
    
    private var internalFiles: [FileSystemEntity] = []
    private var createFolderDialog: CreateFolderDialog?
    private var cellDetail: CellDetail?
    private var lastIndexPath: IndexPath?
    private var diff: (x: CGFloat, y: CGFloat) = (x: 0, y: 0)
    private var style: Style = .table {
        didSet { self.updatePresentationStyle() }
    }
    
    private let internalFilesManager: InternalFilesManagerInterface
    private var delegate: CustomFlowLayoutDelegate?
    
    private struct CellDetail {
        var snapshot: UIView?
        var initialIndexPath: IndexPath?
    }
    
    private enum Style: String, CaseIterable {
        case table
        case grid
        
        var styleIcon: UIImage {
            switch self {
            case .table: return #imageLiteral(resourceName: "gridStyleIcon")
            case .grid: return #imageLiteral(resourceName: "tableStyleIcon")
            }
        }
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
        self.loadDataFromDocumentDirectory()
        self.configureUI()
        self.addGesture()
    }
    
    private func configureUI() {
        self.registerItem()
        self.updatePresentationStyle()
        self.addRightNavigationItem()
        self.collectionView.backgroundColor = .white
    }
    
    private func registerItem() {
        self.collectionView.register(InternalFileTableCell.self, forCellWithReuseIdentifier: String(describing: InternalFileTableCell.self))
        self.collectionView.register(InternalFileGridCell.self, forCellWithReuseIdentifier: String(describing: InternalFileGridCell.self))
    }
    
    // MARK: - Fetch InternalFiles from Document directory
    
    private func loadDataFromDocumentDirectory() {
        self.internalFiles = (try? self.internalFilesManager.fetchFiles()) ?? []
        collectionView.reloadData()
    }
    
    // MARK: - Navigation bar
    
    private func addRightNavigationItem() {
        self.navigationItem.rightBarButtonItems = []
        let createrFolder = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.createFolder))
        let changerContentLayout = UIBarButtonItem(image: style.styleIcon, style: .plain, target: self, action: #selector(self.changeContentLayout))
        self.navigationItem.rightBarButtonItems?.append(changerContentLayout)
        self.navigationItem.rightBarButtonItems?.append(createrFolder)
    }
    
    private func addLeftNavigationItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonClick))
    }
    
    // MARK: - Alert
    
    @objc private func createFolder() {
        self.createFolderDialog = CreateFolderDialog { [weak self] name in
            self?.internalFilesManager.addFolderToFolder(withName: name)
            self?.loadDataFromDocumentDirectory()
            self?.createFolderDialog = nil
        }
        self.createFolderDialog?.show(from: self)
    }
    
    // MARK: - Private
    
    private func removeInternalFile(atPath absolutePath: String) {
        guard FileManager.default.fileExists(atPath: absolutePath) else { return }
        do {
            try FileManager.default.removeItem(atPath: absolutePath)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func moveInternalFile(atPath srcPath: String, toPath dstPath: String) {
        guard FileManager.default.fileExists(atPath: srcPath) else { return }
        do {
            try FileManager.default.moveItem(atPath: srcPath, toPath: dstPath)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func updatePresentationStyle() {
        navigationItem.rightBarButtonItem?.image = style.styleIcon
        switch style {
        case .table:
            delegate = TableLayoutDelegate()
            self.selectItem()
        case .grid:
            delegate = GridLayoutDelegate()
            self.selectItem()
        }
        collectionView.delegate = delegate
        collectionView.reloadData()
    }
    
    @objc private func changeContentLayout() {
        let allCases = Style.allCases
        guard let index = allCases.firstIndex(of: style) else { return }
        let nextIndex = (index + 1) % allCases.count
        style = allCases[nextIndex]
    }
    
    @objc private func doneButtonClick() {
        for row in 0..<self.internalFiles.count {
            guard let cell = collectionView.cellForItem(at: [0, row]) as? InternalFileCellInterface else {
                return
            }
            cell.delButton.isHidden = true
        }
        self.navigationItem.leftBarButtonItem = nil
        self.showRightItems()
        self.selectItem()
    }
    
    private func showRightItems() {
        guard let items = self.navigationItem.rightBarButtonItems else { return }
        for item in items {
            item.isEnabled = true
        }
    }

    // MARK: UICollectionViewDataSource

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
        cell.delButton.isHidden = true
        guard !self.internalFiles.isEmpty else {
            cell.setEmptyDirectoryCell()
            return cell
        }
        cell.name.text = self.internalFiles[indexPath.row].name
        cell.delButton.addTarget(self, action: #selector(delButtonClick(_:)), for: .touchUpInside)
        guard (self.internalFiles[indexPath.row] as? Folder) != nil else {
            cell.iconImageView.image = nil
            cell.iconImageView.isHidden = true
            return cell
        }
        cell.iconImageView.image = UIImage(named: "Folder")
        cell.iconImageView.isHidden = false
        return cell
    }
    
    // MARK: - Delete Item
    
    @objc private func delButtonClick(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? InternalFileCellInterface, let indexPath = collectionView.indexPath(for: cell) else {
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
        self.removeInternalFile(atPath: self.internalFiles[indexPath.row].absolutePath)
        self.internalFiles.remove(at: indexPath.row)
    }
    
    // MARK: - Delegate
    
    func selectItem() {
        guard let delegate = delegate else { return }
        delegate.didSelectItem = { indexPath in
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
            let audioPlayerVC = AudioPlayerViewController(file: selectedFile)
            self.navigationController?.pushViewController(audioPlayerVC, animated: true)
            return
        }
        let internalFilesBuilder = InternalFilesBuilder()
        let internalFilesViewController = internalFilesBuilder.build(path: selectedFile.absolutePath)
        internalFilesViewController.style = self.style
        self.navigationController?.pushViewController(internalFilesViewController, animated: true)
    }
}

// MARK: - Gesture

extension InternalFilesViewController: UIGestureRecognizerDelegate {
    
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
            self.showDelButton()
            self.addLeftNavigationItem()
            self.hideRightItems()
            delegate?.didSelectItem = nil
            self.cellDetail = CellDetail()
            guard let indexPath = indexPathStart, let cellSnapshot = self.cellSnapshot(indexPath, for: collectionView) else {
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
    
    private func moveInternalFile(_ indexPath: IndexPath?, for collectionView: UICollectionView) {
        guard let initialIndexPath = self.cellDetail?.initialIndexPath,
            let cell = collectionView.cellForItem(at: initialIndexPath) as? InternalFileCellInterface,
            !self.internalFiles.isEmpty else {
                return
        }
        if indexPath != initialIndexPath, indexPath?.row != nil,
            let indexPath = indexPath, (self.internalFiles[safe: indexPath.row] as? Folder) != nil {
            self.moveInternalFile(at: initialIndexPath, to: indexPath)
            collectionView.deleteItems(at: [initialIndexPath])
        } else {
            self.cellDetail?.snapshot?.center = cell.center
            cell.isHidden = false
        }
        self.setDefaultCellColor(for: collectionView)
        self.removeSnapshot()
    }
    
    private func moveInternalFile(at initialIndexPath: IndexPath, to indexPath: IndexPath) {
        let srcPath = self.internalFiles[initialIndexPath.row].absolutePath
        let srcName = self.internalFiles[initialIndexPath.row].name
        let dstPath = self.internalFiles[indexPath.row].absolutePath.appendingPathComponent(srcName)
        self.moveInternalFile(atPath: srcPath, toPath: dstPath)
        self.internalFiles.remove(at: initialIndexPath.row)
    }
    
    private func removeSnapshot() {
        self.cellDetail?.snapshot?.removeFromSuperview()
        self.cellDetail = nil
        self.diff.x = 0
        self.diff.y = 0
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
            cell.backgroundColor = .white
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
    
    private func showDelButton() {
        for row in 0..<self.internalFiles.count {
            guard let cell = collectionView.cellForItem(at: [0, row]) as? InternalFileCellInterface else {
                return
            }
            cell.delButton.isHidden = false
        }
    }
    
    private func hideRightItems() {
        guard let items = self.navigationItem.rightBarButtonItems else { return }
        for item in items {
            item.isEnabled = false
        }
    }
}

