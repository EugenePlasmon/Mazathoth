//
//  InternalFilesCollectionViewController.swift
//  Mazathoth
//
//  Created by Nadezhda on 04/10/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesCollectionViewController: UICollectionViewController {
    
    var internalFiles: [FileSystemEntity] = [] {
        didSet { self.onChangingInternalFilesCount?() }
    }
    // TODO: - При переключении style в режиме редактирования сохранять selected сells
    var style: InternalFilesViewController.Style = .table {
        didSet {
            self.updatePresentationStyle()
            self.selectedCellsIndexPaths = []
        }
    }
    private let internalFileManager: InternalFileManagerInterface
    private var internalFilesCollectionGesturesManager: InternalFilesCollectionGesturesManager?
    private var delegate: CustomFlowLayoutDelegate?
    private(set) var isEditingMode: Bool = false
    var selectedCellsIndexPaths: [IndexPath] = [] {
        didSet {
            self.selectedCellsIndexPaths.sort{$0.row > $1.row}
            self.changeSelectedCellsIndexPaths()
        }
    }
    
    var lastScrollOffset: CGFloat = 0
    var lastScrollViewHeight: CGFloat = 0
    
    var onLongPressOnCell: (() -> Void)?
    var onCancelButtonClick: ((URL) -> Void)?
    var onPauseButtonClick: ((URL) -> Void)?
    var onResumeButtonClick: ((URL, String) -> Void)?
    
    var onStartScrolling: ((_ isDown: Bool, _ isUp: Bool, _ contentOffsetDiff: CGFloat) -> Void)?
    var onStopScrolling: (() -> Void)?
    
    var onChangingInternalFilesCount: (() -> Void)?
    var onChangingSelectedCellsIndexPaths: ((_ isSelected: Bool) -> Void)?
    
    // MARK: - Init
    
    init(internalFileManager: InternalFileManagerInterface) {
        self.internalFileManager = internalFileManager
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
        self.collectionView.alwaysBounceVertical = true
        self.updatePresentationStyle()
    }
    
    private func updatePresentationStyle() {
        switch style {
        case .table:
            delegate = TableLayoutDelegate()
            self.selectItem()
            self.startScrolling()
            self.stopScrolling()
        case .grid:
            delegate = GridLayoutDelegate()
            self.selectItem()
            self.startScrolling()
            self.stopScrolling()
        }
        self.collectionView.delegate = delegate
        self.collectionView.reloadData()
    }
    
    // MARK: - Delegate
    
    private func selectItem() {
        guard let delegate = self.delegate else { return }
        delegate.onSelectItem = { indexPath in
            guard !self.internalFiles.isEmpty ,!self.internalFiles[indexPath.row].isDownloading, !self.isEditingMode else { return }
            self.selectItem(indexPath: indexPath)
        }
    }
    
    private func startScrolling() {
        guard let delegate = self.delegate else { return }
        delegate.onStartScrolling = { scrollView in
            self.startScrolling(scrollView)
        }
    }
    
    private func stopScrolling() {
        guard let delegate = self.delegate else { return }
        delegate.onStopScrolling = {
            self.onStopScrolling?()
        }
    }
    
    // MARK: - Router
    
    private func selectItem(indexPath: IndexPath) {
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
        internalFilesViewController.navigationTitle = selectedFile.name
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
        cell.nameLabel.text = self.internalFiles[indexPath.row].name
        cell.configure(isEditing: isEditingMode)
        cell.configure(isDownloading: self.internalFiles[indexPath.row].isDownloading, isActive: self.internalFiles[indexPath.row].isDownloadActive)
        self.configureButtonClickHandlers(for: cell, at: indexPath)
        // TODO: - реализовать icon по типу файла
        guard !self.internalFiles.isEmpty else {
            cell.iconImageView.image = nil
            cell.iconImageView.isHidden = true
            return cell
        }
        cell.iconImageView.image = UIImage(named: "Folder")
        cell.iconImageView.isHidden = false
        return cell
    }
    
    // MARK: - Touch Handlers
    
    private func configureButtonClickHandlers(for cell: InternalFileCellInterface, at indexPath: IndexPath) {
        let download = self.internalFiles[indexPath.row].downloadEntity
        cell.onSelectionButtonClick = { [weak self] isSelected in
            guard let self = self else { return }
            if isSelected {
                self.selectedCellsIndexPaths.append(indexPath)
            } else if self.selectedCellsIndexPaths.contains(indexPath) {
                self.selectedCellsIndexPaths.removeAll(where:{ indexPath == $0 })
            }
        }
        cell.onCancelButtonClick = { [weak self] in
            guard let self = self, let download = download else { return }
            self.onCancelButtonClick?(download.url)
        }
        cell.onPauseButtonClick = { [weak self] in
            guard let self = self, let download = download else { return }
            self.onPauseButtonClick?(download.url)
        }
        cell.onResumeButtonClick = { [weak self] in
            guard let self = self, let download = download else { return }
            let name = self.internalFiles[indexPath.row].name
            self.onResumeButtonClick?(download.url, name)
        }
    }
    
    // MARK: - Delete Items
    
    func deleteInternalFile() {
        guard !self.selectedCellsIndexPaths.isEmpty else { return }
        for indexPath in selectedCellsIndexPaths {
            guard !self.internalFiles.isEmpty else { return }
            self.removeInternalFile(forItemAt: indexPath)
        }
        self.collectionView.reloadData()
        self.selectedCellsIndexPaths = []
    }
    
    private func removeInternalFile(forItemAt indexPath: IndexPath) {
        self.internalFileManager.removeInternalFile(atPath: self.internalFiles[indexPath.row].absolutePath)
        self.internalFiles.remove(at: indexPath.row)
    }
    
    // MARK: - Private
    
    private func handleBeginEditing() {
        for row in 0..<self.internalFiles.count {
            guard let cell = collectionView.cellForItem(at: [0, row]) as? InternalFileCellInterface,
                !self.internalFiles[row].isDownloading else {
                    return
            }
            self.isEditingMode = true
            cell.configure(isEditing: isEditingMode)
            self.onLongPressOnCell?()
        }
    }
    
    private func changeSelectedCellsIndexPaths() {
        if isEditingMode {
            self.onChangingSelectedCellsIndexPaths?(!self.selectedCellsIndexPaths.isEmpty)
        }
    }
    
    // MARK: - Internal
    
    func handleEndEditing() {
        for row in 0..<max(self.internalFiles.count, 1) {
            guard let cell = collectionView.cellForItem(at: [0, row]) as? InternalFileCellInterface else {
                return
            }
            self.isEditingMode = false
            cell.configure(isEditing: isEditingMode)
        }
        self.selectItem()
        self.internalFilesCollectionGesturesManager = nil
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
        if self.internalFilesCollectionGesturesManager == nil {
            self.internalFilesCollectionGesturesManager = InternalFilesCollectionGesturesManager(longPress, for: self.collectionView, internalFiles: self.internalFiles)
            
            self.internalFilesCollectionGesturesManager?.onBeginGesture = {
                self.handleBeginEditing()
            }
            self.internalFilesCollectionGesturesManager?.onEndGesture = { initialIndexPath, indexPath in
                self.moveInternalFile(at: initialIndexPath, to: indexPath)
            }
        }
        self.internalFilesCollectionGesturesManager?.enableGesture()
    }

    private func moveInternalFile(at initialIndexPath: IndexPath, to indexPath: IndexPath) {
        let srcPath = self.internalFiles[initialIndexPath.row].absolutePath
        var srcName = self.internalFiles[initialIndexPath.row].name
        let internalFileManager = InternalFileManager(path: self.internalFiles[indexPath.row].absolutePath)
        let internalFiles = (try? internalFileManager.fetchFiles()) ?? []
        let fileNames = internalFiles.map { $0.name }
        srcName = srcName.unifyName(withAlreadyExistingNames: fileNames)
        let dstPath = self.internalFiles[indexPath.row].absolutePath.appendingPathComponent(srcName)
        self.internalFileManager.moveInternalFile(atPath: srcPath, toPath: dstPath)
        self.internalFiles.remove(at: initialIndexPath.row)
    }
}

//MARK: - Scrolling

extension InternalFilesCollectionViewController {
    
    private func startScrolling(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        defer {
            self.lastScrollViewHeight = scrollView.contentSize.height
            self.lastScrollOffset = contentOffset
        }
        let contentOffsetDiff = contentOffset - self.lastScrollOffset
        let contentHeightDiff = scrollView.contentSize.height - self.lastScrollViewHeight
        guard contentHeightDiff == 0 else { return }
        let isScrollingDown: Bool = contentOffsetDiff > 0 && contentOffset > 0
        let isScrollingUp: Bool = contentOffsetDiff < 0 && contentOffset < 0
        self.onStartScrolling?(isScrollingDown, isScrollingUp, contentOffsetDiff)
    }
}
