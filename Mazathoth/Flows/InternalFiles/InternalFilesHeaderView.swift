//
//  HeaderViewController.swift
//  Mazathoth
//
//  Created by Nadezhda on 29/10/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class InternalFilesHeaderView: UIView {
    
    let maxHeaderHeight: CGFloat = 100
    let midHeaderHeight: CGFloat = 50
    let minHeaderHeight: CGFloat = 0
    
    var onChangerContentLayoutButtonClick: (() -> Void)?
    var onSortButtonClick: (() -> Void)?
    var onSearchBarTextChange: ((_ query: String) -> Void)?
    var onSearchBarCancelButtonClick: (() -> Void)?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
        return label
    }()
    
    let fileСountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13.0)
        return label
    }()
    
    let searchBar: UISearchBar = {
        let searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    let changerContentLayoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "gridStyleIcon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .brandBlue
        return button
    }()
    
    let sortButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "sortIcon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .brandBlue
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(.brandBlue, for: .normal)
        return button
    }()
    
    private let horizontalDistance: CGFloat = 5
    private lazy var changerContentLayoutButtonBottomConstraint = self.changerContentLayoutButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0)
    var changerContentLayoutButtonBottom: CGFloat {
        set { self.changerContentLayoutButtonBottomConstraint.constant = newValue }
        get { return self.changerContentLayoutButtonBottomConstraint.constant }
    }
   
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.buttonАctions()
        self.searchBar.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Аction
    
    private func buttonАctions() {
        self.changerContentLayoutButton.addTarget(self, action: #selector(changeContentLayout(_:)), for: .touchUpInside)
        self.sortButton.addTarget(self, action: #selector(sort), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
    }
    
    @objc private func changeContentLayout(_ sender: UIButton) {
        self.onChangerContentLayoutButtonClick?()
    }
    
    @objc private func sort() {
        self.onSortButtonClick?()
    }
    
    @objc private func cancelSearch() {
        self.sortButton.isHidden = false
        self.changerContentLayoutButton.isHidden = false
        self.cancelButton.isHidden = true
        self.searchBar.text = nil
        self.searchBar.endEditing(true)
        self.onSearchBarCancelButtonClick?()
    }
    
    // MARK: - UI
    
    func configureUI() {
        self.addChangerContentLayoutButton()
        self.addSortButton()
        self.addCancelButton()
        self.addSearchBar()
        self.addFileСountLabel()
        self.addNameLabel()
    }
    
    private func addNameLabel() {
        self.addSubview(self.nameLabel)
        NSLayoutConstraint.activate([
            self.nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 3*self.horizontalDistance),
            self.nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 3*self.horizontalDistance),
            self.nameLabel.bottomAnchor.constraint(equalTo: self.fileСountLabel.topAnchor, constant: 0.0),
            ])
    }
    
    private func addFileСountLabel() {
        self.addSubview(self.fileСountLabel)
        NSLayoutConstraint.activate([
            self.fileСountLabel.bottomAnchor.constraint(equalTo: self.searchBar.topAnchor, constant: 0.0),
            self.fileСountLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 3*self.horizontalDistance),
            self.fileСountLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 3*self.horizontalDistance)
            ])
    }
    
    private func addChangerContentLayoutButton() {
        self.addSubview(self.changerContentLayoutButton)
        NSLayoutConstraint.activate([
            self.changerContentLayoutButtonBottomConstraint,
            self.changerContentLayoutButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -3*self.horizontalDistance)
            ])
    }
    
    private func addSortButton() {
        self.addSubview(self.sortButton)
        NSLayoutConstraint.activate([
            self.sortButton.heightAnchor.constraint(equalTo: self.changerContentLayoutButton.heightAnchor),
            self.sortButton.rightAnchor.constraint(equalTo: self.changerContentLayoutButton.leftAnchor, constant: -self.horizontalDistance),
            self.sortButton.bottomAnchor.constraint(equalTo: self.changerContentLayoutButton.bottomAnchor)
            ])
    }
    
    private func addCancelButton() {
        self.addSubview(self.cancelButton)
        self.cancelButton.isHidden = true
        NSLayoutConstraint.activate([
            self.cancelButton.heightAnchor.constraint(equalTo: self.changerContentLayoutButton.heightAnchor),
            self.cancelButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2*self.horizontalDistance),
            self.cancelButton.leftAnchor.constraint(equalTo: self.sortButton.leftAnchor, constant: 0.0),
            self.cancelButton.centerYAnchor.constraint(equalTo: self.changerContentLayoutButton.centerYAnchor)
            ])
    }

    private func addSearchBar() {
        self.addSubview(self.searchBar)
        self.setSearchTextField()
        NSLayoutConstraint.activate([
            self.searchBar.rightAnchor.constraint(equalTo: self.sortButton.leftAnchor, constant: -self.horizontalDistance),
            self.searchBar.heightAnchor.constraint(equalTo: self.changerContentLayoutButton.heightAnchor),
            self.searchBar.leftAnchor.constraint(equalTo: self.leftAnchor, constant: self.horizontalDistance),
            self.searchBar.bottomAnchor.constraint(equalTo: self.changerContentLayoutButton.bottomAnchor)
            ])
    }

    private func setSearchTextField() {
        let searchTextField = searchBar.searchTextField
        searchTextField.textAlignment = .left
        searchTextField.placeholder = "Поиск"
        searchTextField.borderStyle = .line
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.borderWidth = 1.0
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField.clipsToBounds = true
        searchTextField.clearButtonMode = .never
    }
}

//MARK: - UISearchBarDelegate

extension InternalFilesHeaderView: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.sortButton.isHidden = true
        self.changerContentLayoutButton.isHidden = true
        self.cancelButton.isHidden = false
        self.onSearchBarTextChange?(searchText)
    }
}
