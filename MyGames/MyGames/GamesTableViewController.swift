//
//  GamesTableViewController.swift
//  MyGames
//
//  Created by Douglas Frari on 4/27/21.
//

import UIKit
import CoreData

// GAMES no plural representa nossa lista de jogos
class GamesTableViewController: UITableViewController {
    
    // MARK: - Properties
    var fetchedResultController: NSFetchedResultsController<Game>!
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var gameLabel: UILabel = {
        let label = UILabel()
        label.text = "Você não tem jogos cadastrados"
        label.textAlignment = .center
        return label
    }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // altera comportamento default que adicionava background escuro sobre a view principal
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        
        navigationItem.searchController = searchController
        
        // usando extensions
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        
        self.definesPresentationContext = true
        searchController.definesPresentationContext = true
        
        loadGames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      tableView.reloadData()
    }
    
    // MARK: - Helpers
    // valor default evita precisar ser obrigado a passar o argumento quando chamado
    func loadGames(filtering: String = "") {
        let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if !filtering.isEmpty {
            // usando predicate: conjunto de regras para pesquisas
            // contains [c] = search insensitive (nao considera letras identicas)
            let predicate = NSPredicate(format: "title contains [c] %@", filtering)
            fetchRequest.predicate = predicate
        }
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchedResultController?.fetchedObjects?.count ?? 0
        tableView.backgroundView = count == 0 ? gameLabel : nil
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameTableViewCell
        guard let game = fetchedResultController.fetchedObjects?[indexPath.row] else {
          return cell
        }
             
        cell.prepare(with: game)
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let game = fetchedResultController.fetchedObjects?[indexPath.row] else {return}
            context.delete(game)
            
            do {
                try context.save()
            } catch  {
                print(error.localizedDescription)
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier! == "gameSegue" {
            print("gameSegue")
            let vc = segue.destination as! GameViewController
            
            if let games = fetchedResultController.fetchedObjects {
                vc.game = games[tableView.indexPathForSelectedRow!.row]
            }
            
        } else if segue.identifier! == "newGameSegue" {
            print("newGameSegue")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension GamesTableViewController: NSFetchedResultsControllerDelegate {
    // sempre que algum objeto for modificado esse metodo sera notificado
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
     
        switch type {
            case .delete:
                if let indexPath = indexPath {
                    // Delete the row from the data source
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                break
            default:
                tableView.reloadData()
        }
    }
}

// MARK: - UISearchResultsUpdating, UISearchBarDelegate
extension GamesTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
 
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadGames()
        tableView.reloadData()
     
    }
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadGames(filtering: searchBar.text!)
        tableView.reloadData()
    }
}

