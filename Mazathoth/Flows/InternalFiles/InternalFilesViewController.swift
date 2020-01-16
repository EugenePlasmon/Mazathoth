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
    private let headerView = InternalFilesHeaderView()
    private lazy var headerViewHeightConstraint = self.headerView.heightAnchor.constraint(equalToConstant: 0.0)
    private var headerViewHeight: CGFloat {
        set { self.headerViewHeightConstraint.constant = newValue }
        get { return self.headerViewHeightConstraint.constant }
    }

    enum Style: String, CaseIterable {
        case table
        case grid
        
        var styleIcon: UIImage? {
            switch self {
            case .table: return UIImage(named: "gridStyleIcon")?.withRenderingMode(.alwaysTemplate)
            case .grid: return UIImage(named: "tableStyleIcon")?.withRenderingMode(.alwaysTemplate)
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
        self.configureButtonClickHandlersInCollectionView()
        self.configureStateHandlersInCollectionView()
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
        self.addLoadAddRightNavigationItem()
        self.addNavigationTitle()
    }
    
    private func addLoadAddRightNavigationItem() {
        self.clearRightItems()
        let loadButton: UIButton = UIButton(type: .custom)
        let loadButtonImage = UIImage(named: "loadIcon")?.withRenderingMode(.alwaysTemplate)
        loadButton.setImage(loadButtonImage, for: .normal)
        loadButton.tintColor = .brandBlue
        loadButton.addTarget(self, action: #selector(self.downloadFile), for: .touchUpInside)
        let addButton : UIButton = UIButton(type: .custom)
        let addButtonImage = UIImage(named: "addIcon")?.withRenderingMode(.alwaysTemplate)
        addButton.setImage(addButtonImage, for: .normal)
        addButton.tintColor = .brandBlue
        addButton.addTarget(self, action: #selector(self.createFolder), for: .touchUpInside)
        let loadNavigationItem = UIBarButtonItem(customView: loadButton)
        let addNavigationItem = UIBarButtonItem(customView: addButton)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 5.0
        self.navigationItem.rightBarButtonItems?.append(loadNavigationItem)
        self.navigationItem.rightBarButtonItems?.append(fixedSpace)
        self.navigationItem.rightBarButtonItems?.append(addNavigationItem)
    }
    
    private func addDeleteRightNavigationItem() {
        self.clearRightItems()
        let deleteButton: UIButton = UIButton(type: .custom)
        let deleteButtonImage = UIImage(named: "deleteIcon")?.withRenderingMode(.alwaysTemplate)
        deleteButton.setImage(deleteButtonImage, for: .normal)
        deleteButton.tintColor = .brandBlue
        deleteButton.addTarget(self, action: #selector(self.deleteInternalFile), for: .touchUpInside)
        let deleteNavigationItem = UIBarButtonItem(customView: deleteButton)
        self.navigationItem.rightBarButtonItems?.append(deleteNavigationItem)
    }
    
    @objc private func deleteInternalFile() {
        self.collectionViewController.deleteInternalFile()
    }
    
    private func addDoneLeftNavigationItem() {
        let doneNavigationItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.handleEndEditing))
        doneNavigationItem.tintColor = .brandBlue
        self.navigationItem.leftBarButtonItem = doneNavigationItem
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
        self.navigationItem.backBarButtonItem?.tintColor = .brandBlue
    }
    
    private func showRightItems() {
        self.tuneRightItems(isHidden: false, isEnabled: true)
    }
    
    private func hideRightItems() {
        self.tuneRightItems(isHidden: true, isEnabled: false)
    }
    
    func tuneRightItems(isHidden: Bool = false, isEnabled: Bool = true) {
        guard let items = self.navigationItem.rightBarButtonItems else { return }
        for item in items {
            item.isEnabled = isEnabled
            item.customView?.isHidden = isHidden
        }
    }
    
    private func clearRightItems() {
        guard self.navigationItem.rightBarButtonItems != [] else { return }
        self.navigationItem.rightBarButtonItems = []
    }

    private func clearLeftItems() {
        guard self.navigationItem.leftBarButtonItems != [] else { return }
        self.navigationItem.leftBarButtonItems = []
    }
    
    @objc private func handleEndEditing() {
        self.collectionViewController.handleEndEditing()
        self.clearLeftItems()
        self.addLoadAddRightNavigationItem()
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
    
    // MARK: -  State Handlers In Collection View
    
    private func configureStateHandlersInCollectionView() {
        self.collectionViewController.onChangingInternalFilesCount = {
            self.filteredInternalFiles = self.collectionViewController.internalFiles
            self.loadDataFromDocumentDirectory()
        }
        self.collectionViewController.onChangingSelectedCellsIndexPaths = { [weak self] isEnabled in
            self?.tuneRightItems(isEnabled: isEnabled)
        }
    }
    
    // MARK: - Touch Handlers In Collection View
    
    private func configureButtonClickHandlersInCollectionView() {
        self.collectionViewController.onLongPressOnCell = {
            self.addDoneLeftNavigationItem()
            self.addDeleteRightNavigationItem()
        }
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
    
    // MARK: - Touch Handlers In Header View
    
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
            self.filterAndReloadInternalFiles(query: query)
            if !self.collectionViewController.isEditingMode {
                self.tuneRightItems(isEnabled: false)
            }
        }
        self.headerView.onSearchBarCancelButtonClick = { [weak self] in
            guard let self = self else { return }
            self.filterAndReloadInternalFiles(query: "")
            if !self.collectionViewController.isEditingMode {
                self.showRightItems()
            }
        }
    }
    
    // MARK: -
    
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
        self.collectionViewController.searchBarText = query
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


