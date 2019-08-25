//
//  InternalFilesViewController.swift
//  Mazathoth
//
//  Created by Nadezhda on 04/10/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesViewController: UIViewController {
    
    private let internalFilesManager: InternalFilesManagerInterface
    lazy var collectionViewController = InternalFilesCollectionViewController(internalFilesManager: internalFilesManager)
    private var fileDownloader: FileDownloader?
    private var createFolderDialog: CreateFolderDialog?
    private var downloadFileDialog: DownloadFileDialog?
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
    
    init(internalFilesManager: InternalFilesManagerInterface) {
        self.internalFilesManager = internalFilesManager
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
        self.onClickButtonInCell()
    }
    
    // MARK: - Fetch InternalFiles from Document and Download Directories
    
    func loadDataFromDocumentDirectory() {
        self.internalFiles = (try? self.internalFilesManager.fetchFiles()) ?? []
        self.internalFiles += fileDownloader?.getFiles() ?? []
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
        style = allCases[nextIndex]
    }
    
    // MARK: - Alert
    
    @objc private func createFolder() {
        self.createFolderDialog = CreateFolderDialog { [weak self] name in
            guard let self = self else { return }
            let name = self.collectionViewController.checkName(name)
            self.internalFilesManager.addFolderToFolder(withName: name)
            self.loadDataFromDocumentDirectory()
            self.createFolderDialog = nil
        }
        self.createFolderDialog?.show(from: self)
    }

    @objc private func downloadFile() {
        self.downloadFileDialog = DownloadFileDialog { [weak self] url in
            guard let self = self else { return }
            var fileName: String?
            self.fileDownloader = FileDownloader()
            guard let url = (URL(string: url)) else { return }
            self.fileDownloader?.getFileInfo(from: url) { name in
                self.loadDataFromDocumentDirectory()
                fileName = name
            }
            self.fileDownloader?.downloadFile(from: url) { [weak self] srcPath in
                guard let self = self, let srcPath = srcPath, let documentsDirectoryPath = self.documentsDirectoryPath else {
                    return
                }
                var dstPath = documentsDirectoryPath.appendingPathComponent(fileName ?? url.lastPathComponent)
                if FileManager.default.fileExists(atPath: dstPath) {
                    dstPath = documentsDirectoryPath.appendingPathComponent(self.collectionViewController.checkName(fileName ?? url.lastPathComponent))
                }
                self.internalFilesManager.moveInternalFile(atPath: srcPath, toPath: dstPath)
                DispatchQueue.main.async { self.loadDataFromDocumentDirectory() }
            }
            self.downloadFileDialog = nil
        }
        downloadFileDialog?.show(from: self)
    }
    
    // MARK: - Touch Handlers
    
    private func onClickButtonInCell() {
        self.collectionViewController.onClickOfCancelButton = { [weak self] url in
            self?.fileDownloader?.cancelDownload(from: url)
            DispatchQueue.main.async { self?.loadDataFromDocumentDirectory() }
        }
        self.collectionViewController.onClickOfPauseButton = { [weak self] url in
            self?.fileDownloader?.pauseDownload(from: url)
            DispatchQueue.main.async { self?.loadDataFromDocumentDirectory() }
        }
        self.collectionViewController.onClickOfResumeButton = { [weak self] url, name in
            guard let self = self else { return }
            self.fileDownloader?.resumeDownload(from: url) { srcPath in
                guard let srcPath = srcPath, let documentsDirectoryPath = self.documentsDirectoryPath else { return }
                var dstPath = documentsDirectoryPath.appendingPathComponent(name)
                if FileManager.default.fileExists(atPath: dstPath) {
                    dstPath = documentsDirectoryPath.appendingPathComponent(self.collectionViewController.checkName(name))
                }
                self.internalFilesManager.moveInternalFile(atPath: srcPath, toPath: dstPath)
                DispatchQueue.main.async { self.loadDataFromDocumentDirectory() }
            }
        }
    }
}
