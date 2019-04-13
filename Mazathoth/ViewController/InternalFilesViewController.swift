//
//  InternalFilesViewController.swift
//  Mazathoth
//
//  Created by Nadezhda on 12/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesViewController: UIViewController {
    
    private var internalFiles: [InternalFile] = []
    private let internalFilesView = InternalFilesView()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubviews()
        self.loadDataFromDocumentDirectory()
    }
    
    // MARK: - Fetch InternalFiles from Document directory
    
    private func loadDataFromDocumentDirectory() {
        let internalFilesFetcher = InternalFilesFetcher()
        self.internalFiles = internalFilesFetcher.filesFromDocumentsFolder()
        internalFilesView.tableView.reloadData()
    }
    
    // MARK: - Subview
    
    private func addSubviews() {
        view.addSubview(self.internalFilesView)
        self.internalFilesView.frame = view.bounds
        self.internalFilesView.tableView.delegate = self
        self.internalFilesView.tableView.dataSource = self
    }
}

// MARK: - Delegate

extension InternalFilesViewController: UITableViewDelegate {

}

// MARK: - DataSource

extension InternalFilesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.internalFiles.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: String(describing: InternalFileTableViewCell.self), for: indexPath)
        guard let cell = dequeuedCell as? InternalFileTableViewCell else {
            assertionFailure("Unexpected cell type: \(type(of: dequeuedCell))")
            return dequeuedCell
        }
        guard !self.internalFiles.isEmpty else {
            cell.setEmptyDirectoryCell()
            return cell
        }
        cell.internalFileLabel?.text = self.internalFiles[indexPath.row].name
        return cell
    }
}
