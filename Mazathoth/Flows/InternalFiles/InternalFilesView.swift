//
//  InternalFilesView.swift
//  Mazathoth
//
//  Created by Nadezhda on 12/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesView: UIView {

    let tableView = UITableView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    private func customInit() {
        self.addSubviews()
    }
    
    // MARK: - Subview
    
    private func addSubviews() {
        self.addSubview(tableView)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(InternalFileCell.self, forCellReuseIdentifier: String(describing: InternalFileCell.self))
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.frame = self.bounds
    }
}
