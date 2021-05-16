//
//  CarsTableViewController.swift
//  Carangas
//
//  Created by Eric Brito on 21/10/17.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit
import SideMenu

class CarsTableViewController: UITableViewController {

    // MARK: - Properties
    var cars: [Car] = []
    
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(named: "main")
        return label
    }()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = NSLocalizedString("Carregando dados...", comment: "")
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Define the menus
        SideMenuManager.default.leftMenuNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        // Updated
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: SideMenuManager.PresentDirection.left)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Selectors
    @objc func loadData() {
        REST.loadCars(onComplete: { cars in
            self.cars = cars
            
            if self.cars.count == 0 {
                
                DispatchQueue.main.async {
                    // TODO setar o background
                    self.label.text = "Não existem carros cadastrados."
                    self.tableView.backgroundView = self.label
                }
            } else {
                // precisa recarregar a tableview usando a main UI thread
                DispatchQueue.main.async {
                    // parar animacao do refresh
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }) { error in
            let response = Helper.checkError(error: error)
            Helper.showAlert(title: "Carangas", message: "Erro ao carregar carros: \(response)", over: self)
        }
    }

    // MARK: - UITableViewDatasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cars.count == 0 {
            self.tableView.backgroundView = self.label
        } else {
            self.label.text = ""
            self.tableView.backgroundView = nil
        }
        
        return cars.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let car = cars[indexPath.row]
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = car.brand
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                
        if editingStyle == .delete {
            let car = cars[indexPath.row]
            
            REST.delete(car: car) { success in
                if success {
                    self.cars.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        // Delete the row from the data source
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                } else {
                    Helper.showAlert(title: "Deletar", message: "Não foi possível deletar o carro.", over: self)
                }
            } onError: { error in
                let response = Helper.checkError(error: error)
                Helper.showAlert(title: "Carangas", message: "Erro ao deletar carro: \(response)", over: self)
            }
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSegue" {
            let vc = segue.destination as? CarViewController
            let index = tableView.indexPathForSelectedRow!.row
            vc?.car = cars[index]
        }
    }
}
