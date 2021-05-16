//
//  AboutViewController.swift
//  Carangas
//
//  Created by Pedro Barbosa on 16/05/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var lbDeveloperName: UILabel!
    @IBOutlet weak var lbSubject: UILabel!
    @IBOutlet weak var lbProjectName: UILabel!
    @IBOutlet weak var lbAppVersion: UILabel!
    @IBOutlet var aboutWebView: WKWebView!
    @IBOutlet weak var aivAboutLoading: UIActivityIndicatorView!
    
    // MARK: Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let urlString = "https://github.com/phmb2"
        let urlFixed = urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        let url = URL(string: urlFixed)!
        let request = URLRequest(url: url)
        
        aboutWebView.allowsBackForwardNavigationGestures = true
        aboutWebView.allowsLinkPreview = true // preview usando 3D touch
        aboutWebView.navigationDelegate = self
        aboutWebView.uiDelegate = self
        aboutWebView.load(request)
    }
    
    // MARK: - Helpers
    func configureLayout() {
        view.backgroundColor = .white
        title = "Sobre"
        
        lbDeveloperName.text = "Desenvolvedor: Pedro Henrique Martins Barbosa"
        lbSubject.text = "Disciplina: iOS Network e Persistência de Dados"
        lbProjectName.text = "Projeto: Carangas"
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if let version = appVersion {
            lbAppVersion.text = "Versão do aplicativo: \(version)"
        }
    }
}

// MARK: - WKNavigationDelegate, WKUIDelegate
extension AboutViewController: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        aivAboutLoading.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        aivAboutLoading.stopAnimating()
    }
}
