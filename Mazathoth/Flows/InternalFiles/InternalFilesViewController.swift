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
    private var internalFiles: [FileSystemEntity] = []
    private var filteredInternalFiles: [FileSystemEntity] = [] {
        didSet {
            if self.isDirectSorting {
                self.filteredInternalFiles.sort{$0.name < $1.name}
            } else {
                self.filteredInternalFiles.sort{$0.name > $1.name}
            }
            self.setInternalFilesCount()
        }
    }
    var documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first
    var style: Style = .table {
        didSet {
            self.headerView.changerContentLayoutButton.setImage(style.styleIcon, for: .normal)
            self.collectionViewController.style = self.style
        }
    }
    private var isDirectSorting: Bool = true
    var navigationTitle: String = "Home"
    private let headerView = HeaderView()
    private lazy var headerViewHeightConstraint = self.headerView.heightAnchor.constraint(equalToConstant: 0.0)
    private var headerViewHeight: CGFloat {
        set { self.headerViewHeightConstraint.constant = newValue }
        get { return self.headerViewHeightConstraint.constant }
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
        self.loadData()
        self.configureUI()
        self.configureButtonClickHandlersInCell()
        self.configureButtonClickHandlersInHeaderView()
        self.collectionViewController.onChangingInternalFilesCount = {
            self.filteredInternalFiles = self.collectionViewController.internalFiles
            self.loadDataFromDocumentDirectory()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.changeHeaderViewHeight()
    }
    
    // MARK: - Fetch InternalFiles from Document and Download Directories
    
    private func loadDataFromDocumentDirectory() {
        self.internalFiles = (try? self.internalFileManager.fetchFiles()) ?? []
        self.internalFiles += self.downloadManager?.activeDownloads ?? []
    }
    
    private func loadData() {
        self.loadDataFromDocumentDirectory()
        self.filterInternalFiles(query: "")
        self.reloadCollectionView()
    }
    
    //MARK: - Reload collection view
    
    private func reloadCollectionView() {
        self.collectionViewController.internalFiles = self.filteredInternalFiles
        self.collectionViewController.collectionView.reloadData()
    }

    // MARK: - UI
    
    private func configureUI() {
        self.view.backgroundColor = .white
        self.setNavigationBar()
        self.addHeaderView()
        self.setHeaderСontent()
        self.addCollectionViewController()
    }
    
    private func addHeaderView() {
        self.view.addSubview(self.headerView)
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.headerViewHeightConstraint
            ])
    }
    
    private func addCollectionViewController() {
        self.addChild(self.collectionViewController)
        self.view.addSubview(self.collectionViewController.view)
        self.collectionViewController.didMove(toParent: self)
        self.collectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.collectionViewController.view.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.collectionViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.collectionViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor)
            ])
    }
    
    // MARK: - Navigation bar
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImageView().image, for: .default)
        self.setBackBarButtonItem()
        self.addRightNavigationItem()
        self.addLeftNavigationItem()
        self.addNavigationTitle()
        
    }
    
    private func addRightNavigationItem() {
        self.navigationItem.rightBarButtonItems = []
        let loadButton : UIButton = UIButton(type: .custom)
        loadButton.setImage(#imageLiteral(resourceName: "loadIcon"), for: .normal)
        loadButton.addTarget(self, action: #selector(self.downloadFile), for: .touchUpInside)
        let fileLoader = UIBarButtonItem(customView: loadButton)
        let addButton : UIButton = UIButton(type: .custom)
        addButton.setImage(#imageLiteral(resourceName: "addIcon"), for: .normal)
        addButton.addTarget(self, action: #selector(self.createFolder), for: .touchUpInside)
        let createrFolder = UIBarButtonItem(customView: addButton)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 5.0
        self.navigationItem.rightBarButtonItems?.append(fileLoader)
        self.navigationItem.rightBarButtonItems?.append(fixedSpace)
        self.navigationItem.rightBarButtonItems?.append(createrFolder)
    }
    
    private func addLeftNavigationItem() {
        self.collectionViewController.onLongPressOnCell = {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.handleEndEditing))
            self.navigationItem.leftBarButtonItem?.tintColor = .black
            self.hideRightItems()
        }
    }
    
    private func addNavigationTitle() {
        let label = UILabel()
        label.text = self.navigationTitle
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        let view = UIView()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor),
            label.rightAnchor.constraint(equalTo: view.rightAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.navigationItem.titleView = view
    }
    
    private func setBackBarButtonItem() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = .black
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
    
    @objc private func handleEndEditing() {
        self.collectionViewController.handleEndEditing()
        self.navigationItem.leftBarButtonItem = nil
        self.showRightItems()
    }
    
    private func setNavigationTitle() {
        let range = self.headerView.maxHeaderHeight - self.headerView.minHeaderHeight
        let openAmount = self.headerViewHeight - self.headerView.minHeaderHeight
        let percentage = 1 - openAmount / range
        self.setNavigationTitleAlpha(percentage)
    }
    
    // MARK: - Alert
    
    @objc private func createFolder() {
        self.createFolderPopUp = CreateFolderPopUp { [weak self] name in
            guard let self = self else { return }
            let fileNames = self.filteredInternalFiles.map { $0.name }
            let name = name.unifyName(withAlreadyExistingNames: fileNames)
            self.internalFileManager.addFolder(withName: name)
            self.loadData()
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
                self.loadData()
            }
            self.downloadManager?.onDownloadFile = { srcPath, dstPath in
                self.internalFileManager.moveInternalFile(atPath: srcPath, toPath: dstPath)
                self.loadData()
            }
            self.downloadManager?.downloadFile(from: url)
            self.downloadFilePopUp = nil
        }
        downloadFilePopUp?.show(from: self)
    }
    
    // MARK: - Touch Handlers In Cell
    
    private func configureButtonClickHandlersInCell() {
        self.collectionViewController.onCancelButtonClick = { [weak self] url in
            self?.downloadManager?.cancelDownload(from: url)
            DispatchQueue.main.async { self?.loadData() }
        }
        self.collectionViewController.onPauseButtonClick = { [weak self] url in
            self?.downloadManager?.pauseDownload(from: url)
            DispatchQueue.main.async { self?.loadData() }
        }
        self.collectionViewController.onResumeButtonClick = { [weak self] url, name in
            guard let self = self else { return }
            self.downloadManager?.onDownloadFile = { [weak self] srcPath, dstPath in
                guard let self = self else { return }
                self.internalFileManager.moveInternalFile(atPath: srcPath, toPath: dstPath)
                self.loadData()
            }
            self.downloadManager?.resumeDownload(from: url, name: name)
        }
    }
    
    // MARK: - Touch Handlers In HeaderView
    
    private func configureButtonClickHandlersInHeaderView() {
        self.headerView.onChangerContentLayoutButtonClick = { [weak self] in
            guard let self = self else { return }
            self.changeContentLayout()
        }
        self.headerView.onSortButtonClick = { [weak self] in
            guard let self = self else { return }
            self.isDirectSorting = !self.isDirectSorting
            self.sortInternalFiles()
            self.reloadCollectionView()
        }
        self.headerView.onSearchBarTextChange = { [weak self] query in
            guard let self = self else { return }
            self.hideRightItems()
            self.filterAndReloadInternalFiles(query: query)
        }
        self.headerView.onSearchBarCancelButtonClick = { [weak self] in
            guard let self = self else { return }
            self.showRightItems()
            self.filterAndReloadInternalFiles(query: "")
        }
    }
    
    private func changeContentLayout() {
        let allCases = Style.allCases
        guard let index = allCases.firstIndex(of: style) else { return }
        let nextIndex = (index + 1) % allCases.count
        self.style = allCases[nextIndex]
    }
    
    private func sortInternalFiles() {
        guard self.isDirectSorting else {
            self.filteredInternalFiles.sort{$0.name > $1.name}
            return
        }
        self.filteredInternalFiles.sort{$0.name < $1.name}
    }
   
    //MARK: - Header View
    
    private func changeHeaderViewHeight() {
        self.collectionViewController.onStartScrolling = { isScrollingDown, isScrollingUp, scrollDiff in
            var newHeight = self.headerViewHeight
            if isScrollingDown {
                newHeight = max(self.headerView.minHeaderHeight, self.headerViewHeight - abs(scrollDiff))
            }
            else if isScrollingUp {
                newHeight = min(self.headerView.maxHeaderHeight, self.headerViewHeight + abs(scrollDiff))
            }
            guard newHeight != self.headerViewHeight else { return }
            self.headerViewHeight = newHeight
            self.setNavigationTitle()
        }
        self.collectionViewController.onStopScrolling = {
            let firstPoint = self.headerView.midHeaderHeight / 3
            let secondPoint = self.headerView.maxHeaderHeight * 2/3
            if self.headerViewHeight < self.headerView.midHeaderHeight, self.headerViewHeight > firstPoint {
                self.expandPartHeaderView()
            } else if self.headerViewHeight > self.headerView.midHeaderHeight, self.headerViewHeight > secondPoint {
                self.expandAllHeaderView()
            } else {
                self.collapseHeaderView()
            }
        }
    }
    
    private func collapseHeaderView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.headerViewHeight = self.headerView.minHeaderHeight
            self.setNavigationTitleAlpha(1)
        })
    }

    private func expandAllHeaderView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.headerViewHeight = self.headerView.maxHeaderHeight
            self.setNavigationTitleAlpha(0)
        })
    }
    
    private func expandPartHeaderView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.headerViewHeight = self.headerView.midHeaderHeight
            self.setNavigationTitleAlpha(1)
        })
    }
    
    private func setHeaderСontent() {
        self.headerView.nameLabel.text = self.navigationTitle
        self.setInternalFilesCount()
    }
    
    private func setInternalFilesCount() {
        let internalFilesCount = filteredInternalFiles.count
        self.headerView.fileСountLabel.text = internalFilesCount.addDeclensionFrom(nominativeSingular: "файл", genitiveSingular: "файла", genitivePlural: "файлов")
    }
    
    //MARK: - Private
    
    private func setNavigationTitleAlpha(_ alpha: CGFloat) {
        guard let navigationTitle = self.navigationItem.titleView?.subviews.first,
            navigationTitle is UILabel else {
            return
        }
        navigationTitle.alpha = alpha
    }
    
    private func filterAndReloadInternalFiles(query: String) {
        self.filterInternalFiles(query: query)
        self.reloadCollectionView()
    }
    
    private func filterInternalFiles(query: String) {
        if query.count > 0 {
            self.filteredInternalFiles = self.internalFiles.filter({
                $0.name.lowercased().contains(query.lowercased())
            })
        } else {
            self.filteredInternalFiles = self.internalFiles
        }
    }
}


