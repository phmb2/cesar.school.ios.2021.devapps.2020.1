//
//  ConsoleTableViewCell.swift
//  MyGames
//
//  Created by Pedro Barbosa on 10/05/21.
//

import UIKit

class ConsoleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivConsoleImage: UIImageView!
    @IBOutlet weak var lbConsoleName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func prepare(with console: Console) {
        print("console.name: \(String(describing: console.name))")
        print("console.image: \(String(describing: console.thumbnail))")
        lbConsoleName.text = console.name ?? ""
        if let image = console.thumbnail as? UIImage {
            ivConsoleImage.image = image
        } else {
            ivConsoleImage.image = UIImage(named: "noCover")
        }
    }
}
