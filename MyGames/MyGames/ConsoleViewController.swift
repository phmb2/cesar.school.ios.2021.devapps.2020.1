//
//  ConsoleViewController.swift
//  MyGames
//
//  Created by Pedro Barbosa on 14/05/21.
//

import UIKit

class ConsoleViewController: UIViewController {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    
    // MARK: - Properties
    var console: Console?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    // MARK: - Helpers
    func configureView() {
        lbName.text = console?.name
        
        if let consoleImage = console?.thumbnail as? UIImage {
            ivImage.image = consoleImage
        } else {
            ivImage.image = UIImage(named: "noCoverFull")
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AddEditConsoleViewController
        vc.console = console
    }
}
