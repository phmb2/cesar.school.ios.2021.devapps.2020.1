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
    
    func loadConsoles() {
        ConsolesManager.shared.loadConsoles(with: context)
        tableView.reloadData()
    }

    // MARK: - UITableViewDatasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = ConsolesManager.shared.consoles.count
        print("Count: \(count)")
        tableView.backgroundView = count == 0 ? consoleLabel : nil
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "consoleCell", for: indexPath) as! ConsoleTableViewCell
        let console = ConsolesManager.shared.consoles[indexPath.row]
        print("Console: \(console)")
        cell.prepare(with: console)
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ConsolesManager.shared.deleteConsole(index: indexPath.row, context: context)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "newConsoleSegue" {
            print("newConsoleSegue")
        } else if segue.identifier! == "consoleSegue" {
            let vc = segue.destination as! ConsoleViewController
            vc.console = ConsolesManager.shared.consoles[tableView.indexPathForSelectedRow!.row]
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ConsolesTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            case .delete:
                if let indexPath = indexPath {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                break
            default:
                tableView.reloadData()
        }
    }
}
