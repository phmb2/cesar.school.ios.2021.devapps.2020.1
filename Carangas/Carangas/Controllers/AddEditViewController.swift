//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

enum CarOperationAction {
    case add_car
    case edit_car
    case get_brands
}

class AddEditViewController: UIViewController {

    // MARK: - Properties
    var car: Car!
    var brands: [Brand] = []
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        loadBrands()
    }
    
    // MARK: - Helpers
    func configureLayout() {
        if car != nil {
            tfName?.text = car.name
            tfBrand?.text = car.brand
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar carro", for: .normal)
        }
        
        // criamos uma toolbar e adicionamos como input do textview
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.tintColor = UIColor(named: "main")
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfBrand.inputAccessoryView = toolbar
        tfBrand.inputView = pickerView
    }
    
    func startLoadingAnimation() {
        self.btAddEdit.isEnabled = false
        self.btAddEdit.backgroundColor = .gray
        self.btAddEdit.alpha = 0.5
        self.loading.startAnimating()
    }
    
    func stopLoadingAnimation() {
        self.btAddEdit.isEnabled = true
        self.btAddEdit.backgroundColor = UIColor(named: "main")
        self.btAddEdit.alpha = 0
        self.loading.stopAnimating()
    }
    
    func loadBrands() {
        
        REST.loadBrands { (brands) in
            guard let brands = brands else {return}
            // ascending order
            self.brands = brands.sorted(by: {$0.fipe_name < $1.fipe_name})
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
            }
        } onError: { (error) in
            let response = Helper.checkError(error: error)
            Helper.showAlert(title: "Carangas", message: "Erro ao carregar as marcas de veículos da Tabela FIPE: \(response)", over: self)
        }
    }
    
    // MARK: - Selectors
    @objc func cancel() {
        tfBrand.resignFirstResponder()
    }
    
    @objc func done() {
        tfBrand.text = brands[pickerView.selectedRow(inComponent: 0)].fipe_name
        cancel()
    }
    
    // MARK: - IBActions
    fileprivate func addCar() {
        startLoadingAnimation()
        REST.save(car: car) { success in
            if success {
                self.goBack()
            } else {
                // mostrar um erro generico
                self.showAlert(withTitle: "Adicionar", withMessage: "Não foi possível adicionar o carro.", isTryAgain: true, operation: .add_car)
            }
        } onError: { error in
            print("Error save: \(error)")
            
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
            }
            
            let response = Helper.checkError(error: error)
            Helper.showAlert(title: "Carangas", message: "Erro ao adicionar carro: \(response)", over: self)
        }
    }
    
    fileprivate func updateCar() {
        startLoadingAnimation()
        REST.update(car: car) { success in
            if success {
                self.goBack()
            } else {
                self.showAlert(withTitle: "Editar", withMessage: "Não foi possível editar o carro.", isTryAgain: true, operation: .edit_car)
            }
        } onError: { error in
            print("Error update: \(error)")
            
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
            }
            
            let response = Helper.checkError(error: error)
            Helper.showAlert(title: "Carangas", message: "Erro ao editar carro: \(response)", over: self)
        }
    }
    
    @IBAction func addEdit(_ sender: UIButton) {
        
        if car == nil {
            // adicionar carro novo
            car = Car()
        }
        
        car.name = (tfName?.text)!
        car.brand = (tfBrand?.text)!
        if tfPrice.text!.isEmpty {
            tfPrice.text = "0"
        }
        car.price = Double(tfPrice.text!)!
        car.gasType = scGasType.selectedSegmentIndex
            
        // diferenciar se estamos salvando (SAVE) ou editando (UPDATE)
        if car._id == nil {
            addCar()
        } else {
            updateCar()
        }
    }
    
    // essa função pode fazer um Back na navegação da Navigation Control
    func goBack() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showAlert(withTitle titleMessage: String, withMessage message: String, isTryAgain hasRetry: Bool, operation oper: CarOperationAction) {
        
        if oper != .get_brands {
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
            }
        }
        
        let alert = UIAlertController(title: titleMessage, message: message, preferredStyle: .actionSheet)
        
        if hasRetry {
            let tryAgainAction = UIAlertAction(title: "Tentar novamente", style: .default, handler: {(action: UIAlertAction) in
                
                switch oper {
                    case .add_car:
                        self.addCar()
                    case .edit_car:
                        self.updateCar()
                    case .get_brands:
                        self.loadBrands()
                }
                
            })
            alert.addAction(tryAgainAction)
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {(action: UIAlertAction) in
                self.goBack()
            })
            alert.addAction(cancelAction)
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension AddEditViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let brand = brands[row]
        return brand.fipe_name
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brands.count
    }
}
