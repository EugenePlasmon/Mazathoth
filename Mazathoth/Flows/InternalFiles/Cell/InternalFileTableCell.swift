//
//  InternalFileTableCell.swift
//  Mazathoth
//
//  Created by Nadezhda on 08/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFileTableCell: UICollectionViewCell, InternalFileCellInterface {
    
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
        let image = UIImage(named: "stopIcon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .brandLightBlue
        return button
    }()
    
    private let pauseOrResumeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let pauseImage = UIImage(named: "pauseIcon")?.withRenderingMode(.alwaysTemplate)
        let resumeImage = UIImage(named: "resumeIcon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(pauseImage, for: .normal)
        button.setImage(resumeImage, for: .selected)
        button.tintColor = .brandLightBlue
        return button
    }()
    
    private let selectionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(nil, for: .normal)
        let image = UIImage(named: "checkMark")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .selected)
        button.tintColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    private let longPressView: LongPressView = {
        let view = LongPressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let templateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.text = "No files found"
        return label
    }()
    
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
        self.addTemplateLabel()
        self.addCancelButton()
        self.addPauseOrResumeButton()
    }
    
    // MARK: - Internal
    
    func setEmptyDirectoryCell(_ isTemplate: Bool) {
        self.iconImageView.isHidden = isTemplate
        self.nameLabel.isHidden = isTemplate
        self.templateLabel.isHidden = !isTemplate
    }
    
    func configure(isDownloading: Bool, isActive: Bool) {
        let showDownloadControls = isDownloading
        self.backgroundColor = isDownloading ? UIColor.lightGray.withAlphaComponent(0.2) : .none
        self.pauseOrResumeButton.isHidden = !showDownloadControls
        self.cancelButton.isHidden = !showDownloadControls
        self.longPressView.isHidden = true
        self.pauseOrResumeButton.isSelected = !isActive
    }
        
    func configure(isEditing: Bool, isSelected: Bool) {
        self.selectionButton.isHidden = !isEditing
        self.tuneCell(isLongPress: false, isSelectionButtonSelected: isSelected)
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
        self.pauseOrResumeButton.isSelected = !self.pauseOrResumeButton.isSelected
        if self.pauseOrResumeButton.isSelected {
            self.onPauseButtonClick?()
        } else {
            self.onResumeButtonClick?()
        }
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

    private func addIconImageView() {
        self.contentView.addSubview(self.iconImageView)
        NSLayoutConstraint.activate([
            self.iconImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 22.0),
            self.iconImageView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 1/3),
            self.iconImageView.widthAnchor.constraint(equalTo: self.iconImageView.heightAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
    }
    
    private func addSelectionButton() {
        self.selectionButton.layer.cornerRadius = self.contentView.frame.size.height/4
        self.contentView.addSubview(self.selectionButton)
        NSLayoutConstraint.activate([
            self.selectionButton.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 1/2),
            self.selectionButton.widthAnchor.constraint(equalTo: self.selectionButton.heightAnchor),
            self.selectionButton.centerXAnchor.constraint(equalTo: self.iconImageView.centerXAnchor),
            self.selectionButton.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor)
            ])
    }

    private func addNameLabel() {
        self.contentView.addSubview(self.nameLabel)
        let x = self.contentView.frame.size.height/4 + 20*2
        NSLayoutConstraint.activate([
            self.nameLabel.leftAnchor.constraint(equalTo: self.iconImageView.rightAnchor, constant: 10.0),
            self.nameLabel.rightAnchor.constraint(lessThanOrEqualTo: self.contentView.rightAnchor, constant: -x),
            self.nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20.0),
            self.nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20.0)
            ])
    }
    
    private func addTemplateLabel() {
        self.contentView.addSubview(self.templateLabel)
        NSLayoutConstraint.activate([
            self.templateLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 15.0),
            self.templateLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -55.0),
            self.templateLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20.0),
            self.templateLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -20.0)
            ])
    }
    
    private func addCancelButton() {
        let height = self.contentView.frame.size.height/4
        self.contentView.addSubview(self.cancelButton)
        NSLayoutConstraint.activate([
            self.cancelButton.heightAnchor.constraint(equalToConstant: height),
            self.cancelButton.widthAnchor.constraint(equalTo: self.cancelButton.heightAnchor),
            self.cancelButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -height*6/7),
            self.cancelButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20.0)
            ])
    }
    
    private func addPauseOrResumeButton() {
        let height = self.contentView.frame.size.height/4
        self.contentView.addSubview(self.pauseOrResumeButton)
        NSLayoutConstraint.activate([
            self.pauseOrResumeButton.heightAnchor.constraint(equalToConstant: height),
            self.pauseOrResumeButton.widthAnchor.constraint(equalTo: self.pauseOrResumeButton.heightAnchor),
            self.pauseOrResumeButton.bottomAnchor.constraint(equalTo: self.cancelButton.topAnchor, constant: -height*2/7),
            self.pauseOrResumeButton.centerXAnchor.constraint(equalTo: self.cancelButton.centerXAnchor)
            ])
    }
    
    private func addLongPressView() {
        self.contentView.addSubview(self.longPressView)
        NSLayoutConstraint.activate([
            self.longPressView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8.0),
            self.longPressView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0.0),
            self.longPressView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10.0),
            self.longPressView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10.0)
        ])
    }
}
