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
    
    private var fetcher: InternalFilesManagerInterface
    
    // MARK: - Init
    
    init(fetcher: InternalFilesManagerInterface) {
        self.fetcher = fetcher
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
    }
    
    // MARK: - Fetch InternalFiles from Document directory
    
    private func loadDataFromDocumentDirectory() {
        self.internalFiles = (try? self.fetcher.filesFromDocumentsFolder()) ?? []
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
            self?.fetcher.addFolderToDocumentsFolder(withName: name)
            self?.loadDataFromDocumentDirectory()
        }
        self.createFolderDialog?.show(from: self)
    }
    
    // MARK: - Private
    
    private func removeInternalFile(atPath absolutePath: String) {
        guard FileManager.default.fileExists(atPath: absolutePath) else { return }
        do {
            try FileManager.default.removeItem(atPath: absolutePath)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
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
        guard ((selectedFile as? Folder) != nil) else {
            let audioPlayerVC = AudioPlayerViewController(file: selectedFile)
            self.navigationController?.pushViewController(audioPlayerVC, animated: true)
            return
        }
        self.fetcher.directory = selectedFile.absolutePath
        let internalFilesViewController = InternalFilesViewController(fetcher: fetcher)
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
        guard ((self.internalFiles[indexPath.row] as? Folder) != nil) else {
            cell.iconImageView.isHidden = true
            return cell
        }
        cell.iconImageView.image = UIImage(named: "Folder")
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard !self.internalFiles.isEmpty else { return }
            self.removeInternalFile(atPath: self.internalFiles[indexPath.row].absolutePath)
            self.internalFiles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
