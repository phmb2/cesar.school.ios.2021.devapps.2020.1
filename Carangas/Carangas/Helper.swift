//
//  AlertHelper.swift
//  Carangas
//
//  Created by Pedro Barbosa on 15/05/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import UIKit

class Helper {
    
    static func checkError(error: CarError) -> String {
        var response: String = ""
        
        switch error {
        case .invalidJSON:
            response = "invalidJSON"
        case .noData:
            response = "noData"
        case .noResponse:
            response = "noResponse"
        case .url:
            response = "JSON inválido"
        case .taskError(let error):
            response = "\(error.localizedDescription)"
        case .responseStatusCode(let code):
            if code != 200 {
                response = "Algum problema com o servidor. \nError:\(code)"
            }
        }
        return response
    }
    
    static func showAlert(title: String?, message: String?, over viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alertController, animated: true)
    }
}
