//
//  CreateFolderDialog.swift
//  Mazathoth
//
//  Created by Nadezhda on 23/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class CreateFolderDialog {
    
    typealias OnOkActionClosure = (_ name: String) -> Void
    private let onOkAction: OnOkActionClosure?
    private var alert: UIAlertController?
    private var alertSaveAction: UIAlertAction?
    private let title: String
    private let message: String
    struct DefaultTexts {
        static let title = "Новая папка"
        static let message = "Присвойте название этой папке"
        static let placeholder = "Название"
    }
    
    // MARK: - Init
    
    init(title: String = DefaultTexts.title, message: String = DefaultTexts.message, onOkAction: OnOkActionClosure? = nil) {
        self.title = title
        self.message = message
        self.onOkAction = onOkAction
    }
    
    // MARK: - Show alert
    
    func show(from viewController: UIViewController) {
        self.alert = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
        guard let alert = self.alert else { return }
        alert.addTextField { (textField) in
            textField.placeholder = DefaultTexts.placeholder
        }
        let alertCancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        self.alertSaveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self, weak alert] _ in
            guard let self = self, let alert = alert, let textField = alert.textFields?.first, let name = textField.text else { return }
            self.onOkAction?(name)
        }
        guard let alertSaveAction = self.alertSaveAction else { return }
        alertSaveAction.isEnabled = false
        if let textField = alert.textFields?.first {
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        alert.addAction(alertCancelAction)
        alert.addAction(alertSaveAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange() {
        guard let alert = self.alert, let alertSaveAction = self.alertSaveAction, let textField = alert.textFields?.first, let name = textField.text else { return }
        alertSaveAction.isEnabled = !name.isEmpty
    }
}
