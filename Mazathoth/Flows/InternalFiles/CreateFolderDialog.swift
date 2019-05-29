//
//  CreateFolderDialog.swift
//  Mazathoth
//
//  Created by Nadezhda on 23/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class CreateFolderDialog: NSObject, UITextFieldDelegate {
    
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
            textField.delegate = self
            textField.placeholder = DefaultTexts.placeholder
            textField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        }
        let alertCancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        self.alertSaveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self, weak alert] _ in
            guard let self = self, let alert = alert, let textField = alert.textFields?.first, let name = textField.text else { return }
            self.onOkAction?(name)
        }
        guard let alertSaveAction = self.alertSaveAction else { return }
        alertSaveAction.isEnabled = false
        alert.addAction(alertCancelAction)
        alert.addAction(alertSaveAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange() {
        guard let alert = self.alert, let alertSaveAction = self.alertSaveAction, let textField = alert.textFields?.first, let name = textField.text else { return }
        alertSaveAction.isEnabled = !name.isEmpty
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var set = CharacterSet.alphanumerics
        set.insert(charactersIn: " -_.")
        return string == String(string.unicodeScalars.filter { set.contains($0) })
    }
}
