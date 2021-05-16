//
//  REST.swift
//  Carangas
//
//  Created by Douglas Frari on 5/10/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import Foundation
import Alamofire

enum CarError {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}

enum RESTOperation {
    case save
    case update
    case delete
}

typealias networkComplete = (Bool) -> Void
typealias networkError = (CarError) -> Void

class REST {
    
    // URL + endpoint
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    // URL TABELA FIPE
    private static let urlFipe = "https://fipeapi.appspot.com/api/1/carros/marcas.json"
    
    // session criada automaticamente e disponivel para reusar
    private static let session = URLSession(configuration: configuration)
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.httpAdditionalHeaders = ["Content-Type":"application/json"]
        config.timeoutIntervalForRequest = 10.0
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()
    
    class func delete(car: Car, onComplete: @escaping networkComplete, onError: @escaping networkError) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete, onError: onError)
    }
    
    class func update(car: Car, onComplete: @escaping networkComplete, onError: @escaping networkError) {
        applyOperation(car: car, operation: .update, onComplete: onComplete, onError: onError)
    }
    
    class func save(car: Car, onComplete: @escaping networkComplete, onError: @escaping networkError) {
        applyOperation(car: car, operation: .save, onComplete: onComplete, onError: onError)
    }
    
    class func loadBrands(onComplete: @escaping ([Brand]?) -> Void, onError: @escaping networkError) {
        guard let url = URL(string: urlFipe) else {
            onError(.url)
            return
        }
        
        AF.request(url).responseJSON { (response) in
            if response.error == nil {
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        onError(.noData)
                        return
                    }
                    do {
                        let brands = try JSONDecoder().decode([Brand].self, from: data)
                        onComplete(brands)
                    } catch {
                        print(error.localizedDescription)
                        onError(.invalidJSON)
                    }
                case .failure:
                    print("Status inválido(\(response.response!.statusCode)) pelo servidor!!")
                    onError(.responseStatusCode(code: response.response!.statusCode))
                }
            } else {
                print(response.error.debugDescription)
                onError(.taskError(error: response.error!))
            }
        }
    }
    
    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping networkError) {

        guard let url = URL(string: REST.basePath) else {
            onError(.url)
            return
        }

        AF.request(url).responseJSON { (response) in
            if response.error == nil {
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        onError(.noData)
                        return
                    }
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                    } catch {
                        print(error.localizedDescription)
                        onError(.invalidJSON)
                    }
                case .failure:
                    print("Status inválido(\(response.response!.statusCode)) pelo servidor!!")
                    onError(.responseStatusCode(code: response.response!.statusCode))
                }
            } else {
                print(response.error.debugDescription)
                onError(.taskError(error: response.error!))
            }
        }
    }
    
    private class func applyOperation(car: Car, operation: RESTOperation, onComplete: @escaping networkComplete, onError: @escaping networkError) {
        
        // o endpoint do servidor para update é: URL/id
        let urlString = REST.basePath + "/" + (car._id ?? "")
        
        guard let url = URL(string: urlString) else {
            onError(.url)
            return
        }
        
        var httpMethod: HTTPMethod = .get
        
        switch operation {
        case .delete:
            httpMethod = .delete
        case .save:
            httpMethod = .post
        case .update:
            httpMethod = .put
        }
        
        // transformar objeto para um JSON, processo contrario do decoder -> Encoder
        guard (try? JSONEncoder().encode(car)) != nil else {
            onError(.invalidJSON)
            return
        }
        
        AF.request(url, method: httpMethod, parameters: car, encoder: JSONParameterEncoder.default).response { (response) in
            
            if response.error == nil {
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 200 {
                        onComplete(true)
                    } else {
                        onError(.noData)
                    }
                case .failure(_):
                    print("Status inválido(\(response.response!.statusCode)) pelo servidor!!")
                    onError(.responseStatusCode(code: response.response!.statusCode))
                }
            } else {
                print(response.error.debugDescription)
                onError(.taskError(error: response.error!))
            }
        }
    }
}
