//
//  InternalFilesViewController.swift
//  Mazathoth
//
//  Created by Nadezhda on 04/10/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesViewController: UIViewController {
    
    private let internalFileManager: InternalFileManagerInterface
    lazy var collectionViewController = InternalFilesCollectionViewController(internalFileManager: internalFileManager)
    private var downloadManager: DownloadManager?
    private var createFolderPopUp: CreateFolderPopUp?
    private var downloadFilePopUp: DownloadFilePopUp?
    private var internalFiles: [FileSystemEntity] = [] {
        didSet { internalFiles.sort{$0.name < $1.name} }
    }
    var documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first
    var style: Style = .table {
        didSet {
            self.navigationItem.rightBarButtonItem?.image = style.styleIcon
            self.collectionViewController.style = self.style
        }
    }
    
    enum Style: String, CaseIterable {
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
    
    init(internalFileManager: InternalFileManagerInterface) {
        self.internalFileManager = internalFileManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.loadDataFromDocumentDirectory()
        self.configureButtonClickHandlersInCell()
    }
    
    // MARK: - Fetch InternalFiles from Document and Download Directories
    
    private func loadDataFromDocumentDirectory() {
        self.internalFiles = (try? self.internalFileManager.fetchFiles()) ?? []
        self.internalFiles += self.downloadManager?.activeDownloads ?? []
        self.collectionViewController.internalFiles = self.internalFiles
        self.collectionViewController.collectionView.reloadData()
    }

    // MARK: - UI
    
    private func configureUI() {
        self.view.backgroundColor = .white
        self.addCollectionViewController()
        self.addRightNavigationItem()
        self.addLeftNavigationItem()
    }
    
    private func addCollectionViewController() {
        self.addChild(self.collectionViewController)
        self.view.addSubview(self.collectionViewController.view)
        self.collectionViewController.didMove(toParent: self)
        
        self.collectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.collectionViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.collectionViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.collectionViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor)
            ])
    }
    
    private func showRightItems() {
        guard let items = self.navigationItem.rightBarButtonItems else { return }
        for item in items {
            item.isEnabled = true
        }
    }
    
    private func hideRightItems() {
        guard let items = self.navigationItem.rightBarButtonItems else { return }
        for item in items {
            item.isEnabled = false
        }
    }
    
    // MARK: - Navigation bar
    
    private func addRightNavigationItem() {
        self.navigationItem.rightBarButtonItems = []
        let createrFolder = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.createFolder))
        let changerContentLayout = UIBarButtonItem(image: style.styleIcon, style: .plain, target: self, action: #selector(self.changeContentLayout))
        let fileLoader = UIBarButtonItem(image: #imageLiteral(resourceName: "loadIcon"), style: .plain, target: self, action: #selector(self.downloadFile))
        self.navigationItem.rightBarButtonItems?.append(changerContentLayout)
        self.navigationItem.rightBarButtonItems?.append(fileLoader)
        self.navigationItem.rightBarButtonItems?.append(createrFolder)
    }
    
    private func addLeftNavigationItem() {
        self.collectionViewController.onLongPressOnCell = {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.handleEndEditing))
            self.hideRightItems()
        }
    }
    
    @objc private func handleEndEditing() {
        self.collectionViewController.handleEndEditing()
        self.navigationItem.leftBarButtonItem = nil
        self.showRightItems()
    }
    
    @objc private func changeContentLayout() {
        let allCases = Style.allCases
        guard let index = allCases.firstIndex(of: style) else { return }
        let nextIndex = (index + 1) % allCases.count
        self.style = allCases[nextIndex]
    }
    
    // MARK: - Alert
    
    @objc private func createFolder() {
        self.createFolderPopUp = CreateFolderPopUp { [weak self] name in
            guard let self = self else { return }
            let fileNames = self.internalFiles.map { $0.name }
            let name = name.unifyName(withAlreadyExistingNames: fileNames)
            self.internalFileManager.addFolder(withName: name)
            self.loadDataFromDocumentDirectory()
            self.createFolderPopUp = nil
        }
        self.createFolderPopUp?.show(from: self)
    }
    
    @objc private func downloadFile() {
        self.downloadFilePopUp = DownloadFilePopUp { [weak self] url in
            guard let self = self, let documentsDirectoryPath = self.documentsDirectoryPath else {
                return
            }
            self.downloadManager = DownloadManager(documentsDirectoryPath: documentsDirectoryPath)
            self.downloadManager?.onGetFileInfo = {
                self.loadDataFromDocumentDirectory()
            }
            self.downloadManager?.onDownloadFile = { srcPath, dstPath in
                self.internalFileManager.moveInternalFile(atPath: srcPath, toPath: dstPath)
                self.loadDataFromDocumentDirectory()
            }
            self.downloadManager?.downloadFile(from: url)
            self.downloadFilePopUp = nil
        }
        downloadFilePopUp?.show(from: self)
    }
    
    // MARK: - Touch Handlers
    
    private func configureButtonClickHandlersInCell() {
        self.collectionViewController.onCancelButtonClick = { [weak self] url in
            self?.downloadManager?.cancelDownload(from: url)
            DispatchQueue.main.async { self?.loadDataFromDocumentDirectory() }
        }
        self.collectionViewController.onPauseButtonClick = { [weak self] url in
            self?.downloadManager?.pauseDownload(from: url)
            DispatchQueue.main.async { self?.loadDataFromDocumentDirectory() }
        }
        self.collectionViewController.onResumeButtonClick = { [weak self] url, name in
            guard let self = self else { return }
            self.downloadManager?.onDownloadFile = { srcPath, dstPath in
                self.internalFileManager.moveInternalFile(atPath: srcPath, toPath: dstPath)
                self.loadDataFromDocumentDirectory()
            }
            self.downloadManager?.resumeDownload(from: url, name: name)
        }
    }
}
