//
//  DownloadFileDialog.swift
//  Mazathoth
//
//  Created by Nadezhda on 24/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class DownloadFileDialog: NSObject {
    
    typealias OnOkActionClosure = (_ url: String) -> Void
    private let onOkAction: OnOkActionClosure?
    private var alert: UIAlertController?
    private var alertDownloadAction: UIAlertAction?
    private let title: String
    private let message: String
    struct DefaultTexts {
        static let title = "Download"
        static let message = "Вставьте ссылку для загрузки файла"
        static let placeholder = "URL"
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
            textField.delegate = self as? UITextFieldDelegate
            textField.placeholder = DefaultTexts.placeholder
            textField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        }
        let alertCancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        self.alertDownloadAction = UIAlertAction(title: "Скачать", style: .default) { [weak self, weak alert] _ in
            guard let self = self, let alert = alert, let textField = alert.textFields?.first, let url = textField.text else { return }
            self.onOkAction?(url)
        }
        guard let alertDownloadAction = self.alertDownloadAction else { return }
        alertDownloadAction.isEnabled = false
        alert.addAction(alertCancelAction)
        alert.addAction(alertDownloadAction)
        viewController.present(alert, animated: true, completion: nil)
    }

    @objc private func textFieldDidChange() {
        guard let alert = self.alert, let alertDownloadAction = self.alertDownloadAction, let textField = alert.textFields?.first, let name = textField.text else { return }
        alertDownloadAction.isEnabled = !name.isEmpty
    }
}

