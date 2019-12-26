//
//  InternalFileGridCell.swift
//  Mazathoth
//
//  Created by Nadezhda on 18/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFileGridCell: UICollectionViewCell, InternalFileCellInterface {
    
    let nameLabel: UILabel = {
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
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("cancel", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        return button
    }()
    
    private let pauseOrResumeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        return button
    }()
    
    private let selectionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(nil, for: .normal)
        button.setImage(UIImage(named: "checkMark"), for: .selected)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    private let longPressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .brandLightBlue
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private enum DownloadStatus: String {
        case pause
        case resume
    }
    
    var onSelectionButtonClick: ((Bool) -> Void)?
    var onCancelButtonClick: (() -> Void)?
    var onPauseButtonClick: (() -> Void)?
    var onResumeButtonClick: (() -> Void)?
    
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
    
    // MARK: - Button Аctions
    
    private func buttonАctions() {
        self.selectionButton.addTarget(self, action: #selector(self.selectCell), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(cancelDownload(_:)), for: .touchUpInside)
        self.pauseOrResumeButton.addTarget(self, action: #selector(pauseOrResumeDownload(_:)), for: .touchUpInside)
    }
    
    // MARK: - UI
    
    private func configureUI() {
        self.backgroundColor = .white
        self.addUIElements()
    }
    
    private func addUIElements() {
        self.addLongPressView()
        self.addIconImageView()
        self.addSelectionButton()
        self.addNameLabel()
        self.addCancelButton()
        self.addPauseButton()
    }
    
    // MARK: - Internal
    
    func setEmptyDirectoryCell() {
        self.iconImageView.image = nil
        self.nameLabel.text = "No files found"
    }
    
    func configure(isDownloading: Bool, isActive: Bool) {
        let showDownloadControls = isDownloading
        self.backgroundColor = isDownloading ? UIColor.lightGray.withAlphaComponent(0.5) : .none
        self.pauseOrResumeButton.isHidden = !showDownloadControls
        self.cancelButton.isHidden = !showDownloadControls
        
        let title: String = isActive ? DownloadStatus.pause.rawValue : DownloadStatus.resume.rawValue
        pauseOrResumeButton.setTitle(title, for: .normal)
    }
    
    func configure(isEditing: Bool) {
        self.selectionButton.isHidden = !isEditing
        self.tuneCell(isLongPress: false, isSelectionButtonSelected: false)
    }
    
    func configure(isLongPress: Bool) {
        self.tuneCell(isLongPress: isLongPress, isSelectionButtonSelected: true)
        if isLongPress {
            self.onSelectionButtonClick?(isLongPress)
        }
    }
    
    // MARK: - Action
    
    @objc private func selectCell() {
        self.selectionButton.isSelected = !self.selectionButton.isSelected
        self.setSelectionButtonColor()
        self.onSelectionButtonClick?(self.selectionButton.isSelected)
    }
    
    @objc private func cancelDownload(_ sender: UIButton) {
        self.onCancelButtonClick?()
    }
    
    @objc private func pauseOrResumeDownload(_ sender: UIButton) {
        let title: String
        if (pauseOrResumeButton.titleLabel?.text == DownloadStatus.pause.rawValue) {
            title = DownloadStatus.resume.rawValue
            self.onPauseButtonClick?()
        } else {
            title = DownloadStatus.pause.rawValue
            self.onResumeButtonClick?()
        }
        pauseOrResumeButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Private
    
    private func tuneCell(isLongPress: Bool, isSelectionButtonSelected: Bool) {
        self.longPressView.isHidden = !isLongPress
        self.selectionButton.isSelected = isSelectionButtonSelected
        self.setSelectionButtonColor()
    }
    
    private func setSelectionButtonColor() {
        self.selectionButton.layer.borderColor = self.selectionButton.isSelected ? UIColor.clear.cgColor : UIColor.lightGray.cgColor
        self.selectionButton.backgroundColor = self.selectionButton.isSelected ? .brandBlue : .clear
    }
    
    func addIconImageView() {
        self.contentView.addSubview(self.iconImageView)
        NSLayoutConstraint.activate([
            self.iconImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.iconImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8.0),
            self.iconImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8.0)
            ])
        self.iconImageView.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        self.iconImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
    }
    
    private func addSelectionButton() {
        self.selectionButton.layer.cornerRadius = self.contentView.frame.size.height/8
        
        self.contentView.addSubview(self.selectionButton)
        NSLayoutConstraint.activate([
            self.selectionButton.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.selectionButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            self.selectionButton.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 1/4),
            self.selectionButton.widthAnchor.constraint(equalTo: self.selectionButton.heightAnchor)
            ])
    }
    
    func addNameLabel() {
        self.contentView.addSubview(self.nameLabel)
        NSLayoutConstraint.activate([
            self.nameLabel.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor),
            self.nameLabel.leftAnchor.constraint(greaterThanOrEqualTo: self.contentView.leftAnchor, constant: 8.0),
            self.nameLabel.rightAnchor.constraint(lessThanOrEqualTo: self.contentView.rightAnchor, constant: -8.0),
            self.nameLabel.heightAnchor.constraint(equalToConstant: 60),
            self.nameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
            ])
    }
    
    private func addCancelButton() {
        self.contentView.addSubview(self.cancelButton)
        NSLayoutConstraint.activate([
            self.cancelButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -2.0),
            self.cancelButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8.0),
            ])
    }
    
    private func addPauseButton() {
        self.contentView.addSubview(self.pauseOrResumeButton)
        NSLayoutConstraint.activate([
            self.pauseOrResumeButton.rightAnchor.constraint(equalTo: self.cancelButton.leftAnchor, constant: -8.0),
            self.pauseOrResumeButton.centerYAnchor.constraint(equalTo: self.cancelButton.centerYAnchor)
            ])
    }
    
    private func addLongPressView() {
        self.contentView.addSubview(self.longPressView)
        NSLayoutConstraint.activate([
             self.longPressView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 5.0),
             self.longPressView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -5.0),
             self.longPressView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5.0),
             self.longPressView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5.0)
        ])
    }
}
