//
//  AlertManager.swift
//  Mazathoth
//
//  Created by Nadezhda on 23/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class AlertManager {
    
    func createFolder(viewController: UIViewController) {
        let alertController = UIAlertController(title: "Новая папка", message: "Присвойте название этой папке", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Название"
        }
        let alertCancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let alertSaveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak alertController] _ in
            guard let alertController = alertController, let textField = alertController.textFields?.first, let nameFolder = textField.text else { return }
            //self.fetcher.addFolderToDocumentsFolder(whithName: nameFolder)
            //self.loadDataFromDocumentDirectory()
            //self.internalFilesView.tableView.reloadData()
        }
        alertController.addAction(alertCancelAction)
        alertController.addAction(alertSaveAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
