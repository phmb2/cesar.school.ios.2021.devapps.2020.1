//
//  ConsolesTableViewController.swift
//  MyGames
//
//  Created by Douglas Frari on 4/27/21.
//

import UIKit
import CoreData

class ConsolesTableViewController: UITableViewController {
    
    // MARK: - Properties
    var consolesManager = ConsolesManager.shared
    
    lazy var consoleLabel: UILabel = {
        let label = UILabel()
        label.text = "Você não tem consoles cadastrados"
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadConsoles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Helpers
    func loadConsoles() {
        consolesManager.loadConsoles(with: context)
        tableView.reloadData()
    }

    // MARK: - UITableViewDatasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = consolesManager.consoles.count
        tableView.backgroundView = count == 0 ? consoleLabel : nil
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let console = consolesManager.consoles[indexPath.row]
        cell.textLabel?.text = console.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let console = consolesManager.consoles[indexPath.row]
        //showAlert(with: console)
        //prepare(for: <#T##UIStoryboardSegue#>, sender: <#T##Any?#>)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            consolesManager.deleteConsole(index: indexPath.row, context: context)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "newConsoleSegue" {
            print("newConsoleSegue")
        }
    }
    
    @IBAction func addConsole(_ sender: Any) {
        //showAlert(with: nil)
    }
    
//    func showAlert(with console: Console?) {
//        let title = console == nil ? "Adicionar" : "Editar"
//        let alert = UIAlertController(title: title + " plataforma", message: nil, preferredStyle: .alert)
//
//        alert.addTextField(configurationHandler: { (textField) in
//            textField.placeholder = "Nome da plataforma"
//
//            if let name = console?.name {
//                textField.text = name
//            }
//        })
//
//        alert.addAction(UIAlertAction(title: title, style: .default, handler: {(action) in
//            let console = console ?? Console(context: self.context)
//            console.name = alert.textFields?.first?.text
//            do {
//                try self.context.save()
//                self.loadConsoles()
//            } catch {
//                print(error.localizedDescription)
//            }
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
//        alert.view.tintColor = UIColor(named: "second")
//
//        present(alert, animated: true, completion: nil)
//    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension ConsolesTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
}
