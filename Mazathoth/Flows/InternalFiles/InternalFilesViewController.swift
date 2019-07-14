//
//  InternalFilesViewController.swift
//  Mazathoth
//
//  Created by Nadezhda on 12/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesViewController: UIViewController {
    
    private var internalFiles: [FileSystemEntity] = []
    private let internalFilesView = InternalFilesView()
    private var createFolderDialog: CreateFolderDialog?
    private var cellDetail: CellDetail?
    private var lastIndexPath: IndexPath?
    private var diff: CGFloat?
    
    private let internalFilesManager: InternalFilesManagerInterface
    
    private struct CellDetail {
        var snapshot: UIView?
        var initialIndexPath: IndexPath?
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
        self.addSubviews()
        self.addNavigationItem()
        self.loadDataFromDocumentDirectory()
        self.addGesture()
    }
    
    // MARK: - Fetch InternalFiles from Document directory
    
    private func loadDataFromDocumentDirectory() {
        self.internalFiles = (try? self.internalFilesManager.fetchFiles()) ?? []
        self.internalFilesView.tableView.reloadData()
    }
    
    // MARK: - Subview
    
    private func addSubviews() {
        view.addSubview(self.internalFilesView)
        self.internalFilesView.frame = view.bounds
        self.internalFilesView.tableView.delegate = self
        self.internalFilesView.tableView.dataSource = self
    }
    
    // MARK: - Navigation bar
    
    private func addNavigationItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.createFolder))
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
}

// MARK: - Delegate

extension InternalFilesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        self.navigationController?.pushViewController(internalFilesViewController, animated: true)
    }
}

// MARK: - DataSource

extension InternalFilesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.internalFiles.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: String(describing: InternalFileCell.self), for: indexPath)
        guard let cell = dequeuedCell as? InternalFileCell else {
            assertionFailure("Unexpected cell type: \(type(of: dequeuedCell))")
            return dequeuedCell
        }
        guard !self.internalFiles.isEmpty else {
            cell.setEmptyDirectoryCell()
            return cell
        }
        cell.name.text = self.internalFiles[indexPath.row].name
        guard (self.internalFiles[indexPath.row] as? Folder) != nil else {
            cell.iconImageView.image = nil
            cell.iconImageView.isHidden = true
            return cell
        }
        cell.iconImageView.image = UIImage(named: "Folder")
        cell.iconImageView.isHidden = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, !self.internalFiles.isEmpty else { return }
        self.removeInternalFile(forRowAt: indexPath)
        if self.internalFiles.count == 0 {
            tableView.reloadData()
        } else {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func removeInternalFile(forRowAt indexPath: IndexPath) {
        self.removeInternalFile(atPath: self.internalFiles[indexPath.row].absolutePath)
        self.internalFiles.remove(at: indexPath.row)
    }
}

// MARK: - Gesture

extension InternalFilesViewController: UIGestureRecognizerDelegate {
    
    private func addGesture() {
        let longPressOnCell = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCellGestureRecognized(_:)))
        self.internalFilesView.tableView.addGestureRecognizer(longPressOnCell)
    }
    
    @objc private func longPressOnCellGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        guard let longPress = gestureRecognizer as? UILongPressGestureRecognizer else {
            return
        }
        let tableView = self.internalFilesView.tableView
        let state = longPress.state
        let location = longPress.location(in: tableView)
        let locationWithDiff = CGPoint(x: location.x, y: location.y - (diff ?? 0))
        let indexPathStart = tableView.indexPathForRow(at: location)
        let indexPath = tableView.indexPathForRow(at: locationWithDiff)
        
        switch state {
        case .began:
            self.cellDetail = CellDetail()
            guard let indexPath = indexPathStart, let cellSnapshot = self.cellSnapshot(indexPath, for: tableView) else {
                return
            }
            self.diff = location.y - cellSnapshot.center.y
            tableView.addSubview(cellSnapshot)
        case .changed:
            guard let cellSnapshot = self.cellDetail?.snapshot, let diff = self.diff else {
                return
            }
            cellSnapshot.center.y = location.y - diff
            guard let indexPath = indexPath, (self.internalFiles[safe: (indexPath.row)] as? Folder) != nil  else {
                self.setDefaultCellColor(for: tableView)
                return
            }
            self.changeCellColor(indexPath, for: tableView)
        case .ended:
            self.moveInternalFile(indexPath, for: tableView)
        case .cancelled:
            self.cancelCellAction(indexPath, for: tableView)
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    private func cellSnapshot(_ indexPath: IndexPath, for tableView: UITableView) -> UIView? {
        guard let cell = tableView.cellForRow(at: indexPath) as? InternalFileCell else {
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
    
    private func moveInternalFile(_ indexPath: IndexPath?, for tableView: UITableView) {
        guard let initialIndexPath = self.cellDetail?.initialIndexPath,
            let cell = tableView.cellForRow(at: initialIndexPath) as? InternalFileCell,
            !self.internalFiles.isEmpty else {
                return
        }
        if indexPath != initialIndexPath, indexPath?.row != nil,
            let indexPath = indexPath, (self.internalFiles[safe: indexPath.row] as? Folder) != nil {
            self.moveInternalFile(at: initialIndexPath, to: indexPath)
            tableView.deleteRows(at: [initialIndexPath], with: .fade)
        } else {
            self.cellDetail?.snapshot?.center = cell.center
            cell.isHidden = false
        }
        self.setDefaultCellColor(for: tableView)
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
        self.diff = nil
    }
    
    private func changeCellColor(_ indexPath: IndexPath, for tableView: UITableView) {
        guard let cell = tableView.cellForRow(at: indexPath) as? InternalFileCell else {
                return
        }
        cell.backgroundColor = .lightGray
        guard self.lastIndexPath != indexPath else {
            return
        }
        if self.lastIndexPath != nil {
            self.setDefaultCellColor(for: tableView)
            self.lastIndexPath = nil
        } else {
            self.lastIndexPath = indexPath
        }
    }
    
    private func setDefaultCellColor(for tableView: UITableView) {
        for row in 0..<self.internalFiles.count {
            guard let cell = tableView.cellForRow(at: [0, row]) as? InternalFileCell else {
                return
            }
            cell.backgroundColor = .white
        }
    }
    
    private func cancelCellAction(_ indexPath: IndexPath?, for tableView: UITableView) {
        guard let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? InternalFileCell else {
            return
        }
        cell.isHidden = false
        self.setDefaultCellColor(for: tableView)
        self.removeSnapshot()
    }
}
