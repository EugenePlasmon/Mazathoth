//
//  InternalFileCell.swift
//  Mazathoth
//
//  Created by Nadezhda on 23/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class InternalFileCell: UICollectionViewCell, InternalFileCellInterface {
    
    let name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.numberOfLines = 0
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let delButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "deleteIcon"), for: .normal)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("cancel", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        return button
    }()
    
    let pauseOrResumeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        return button
    }()
    
    private enum downloadStatusTitle: String {
        case pause
        case resume
    }
    
    var onClickOfDelButton: (() -> Void)?
    var onClickOfCancelButton: (() -> Void)?
    var onClickOfPauseButton: (() -> Void)?
    var onClickOfResumeButton: (() -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.buttonАctions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureUI()
        self.buttonАctions()
    }
    
    func setEmptyDirectoryCell() {
        self.iconImageView.image = nil
        self.name.text = "No files found"
    }
    
    private func buttonАctions() {
        self.delButton.addTarget(self, action: #selector(delCell(_:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(cancelDownload(_:)), for: .touchUpInside)
        self.pauseOrResumeButton.addTarget(self, action: #selector(pauseOrResumeDownload(_:)), for: .touchUpInside)
    }
    
    // MARK: - UI
    
    private func configureUI() {
        self.backgroundColor = .white
        self.addDelButton()
        self.addUIElements()
    }
    
    private func addDelButton() {
        self.contentView.addSubview(self.delButton)
        NSLayoutConstraint.activate([
            self.delButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.delButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8.0),
            self.delButton.widthAnchor.constraint(equalToConstant: 20.0),
            self.delButton.heightAnchor.constraint(equalToConstant: 20.0)
            ])
    }
    
    func addUIElements() {
    }
    
    func configure(isDownloading: Bool, isActive: Bool) {
        let showDownloadControls = isDownloading
        self.backgroundColor = isDownloading ? UIColor.lightGray.withAlphaComponent(0.5) : .none
        self.pauseOrResumeButton.isHidden = !showDownloadControls
        self.cancelButton.isHidden = !showDownloadControls
        
        let title: String = isActive ? downloadStatusTitle.pause.rawValue : downloadStatusTitle.resume.rawValue
        pauseOrResumeButton.setTitle(title, for: .normal)
    }
    
    func configure(isEditing: Bool) {
        self.delButton.isHidden = !isEditing
    }
    
    // MARK: - Action
    
    @objc private func delCell(_ sender: UIButton) {
        self.onClickOfDelButton?()
    }
    
    @objc private func cancelDownload(_ sender: UIButton) {
        self.onClickOfCancelButton?()
    }
    
    @objc private func pauseOrResumeDownload(_ sender: UIButton) {
        let title: String
        if (pauseOrResumeButton.titleLabel?.text == downloadStatusTitle.pause.rawValue) {
            title = downloadStatusTitle.resume.rawValue
            self.onClickOfPauseButton?()
        } else {
            title = downloadStatusTitle.pause.rawValue
            self.onClickOfResumeButton?()
        }
        pauseOrResumeButton.setTitle(title, for: .normal)
    }
}

