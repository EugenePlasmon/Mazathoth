//
//  HeaderViewController.swift
//  Mazathoth
//
//  Created by Nadezhda on 29/10/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
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
    
    private let horizontalDistance: CGFloat = 5
    private lazy var changerContentLayoutButtonBottomConstraint = self.changerContentLayoutButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0)
    var changerContentLayoutButtonBottom: CGFloat {
        set { self.changerContentLayoutButtonBottomConstraint.constant = newValue }
        get { return self.changerContentLayoutButtonBottomConstraint.constant }
    }
    private lazy var searchBarRightConstraint = self.searchBar.rightAnchor.constraint(equalTo: self.sortButton.leftAnchor, constant: -self.horizontalDistance)
    var searchBarRight: CGFloat {
        set { self.searchBarRightConstraint.constant = newValue }
        get { return self.searchBarRightConstraint.constant }
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
    
    //MARK: - 
    
    private func buttonАctions() {
        self.changerContentLayoutButton.addTarget(self, action: #selector(changeContentLayout(_:)), for: .touchUpInside)
        self.sortButton.addTarget(self, action: #selector(sort), for: .touchUpInside)
    }
    
    @objc private func changeContentLayout(_ sender: UIButton) {
        self.onChangerContentLayoutButtonClick?()
    }
    
    @objc private func sort() {
        self.onSortButtonClick?()
    }
    
    // MARK: - UI
    
    func configureUI() {
        self.addChangerContentLayoutButton()
        self.addSortButton()
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

    private func addSearchBar() {
        self.addSubview(self.searchBar)
        self.setSearchTextField()
        NSLayoutConstraint.activate([
            self.searchBarRightConstraint,
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
    
    private func setCancelButton() {
        (searchBar.value(forKey: "cancelButton") as! UIButton).setTitle("Отмена", for: .normal)
    }
}

//MARK: - UISearchBarDelegate

extension HeaderView: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.sortButton.isHidden = true
        self.changerContentLayoutButton.isHidden = true
        searchBar.showsCancelButton = true
        self.setCancelButton()
        self.searchBarRight = self.changerContentLayoutButton.frame.size.width + self.sortButton.frame.size.width + self.horizontalDistance
        self.onSearchBarTextChange?(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.sortButton.isHidden = false
        self.changerContentLayoutButton.isHidden = false
        searchBar.showsCancelButton = false
        searchBar.text = nil
        searchBar.endEditing(true)
        searchBarRight = -self.horizontalDistance
        self.onSearchBarCancelButtonClick?()
    }
}
