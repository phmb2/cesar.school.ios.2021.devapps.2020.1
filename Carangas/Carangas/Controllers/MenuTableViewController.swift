//
//  MenuTableViewController.swift
//  Carangas
//
//  Created by Pedro Barbosa on 16/05/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }

    // MARK: - UITableViewDatasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
}
