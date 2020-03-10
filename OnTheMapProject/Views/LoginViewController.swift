//
//  ViewController.swift
//  OnTheMapProject
//
//  Created by Andrey Valverde Solera on 3/6/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadingIndicator.isHidden = true
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        // Start animating the loading indicator
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
        
        UdacityClient.createSession(email: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleCreateSession(success:error:))
    }
    
    private func handleCreateSession(success: Bool, error: Error?) {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        
        if success {
            performSegue(withIdentifier: "MainTabBarController", sender: nil)
        } else {
            // There was an error login in
            self.showError(errorMessage: error!.localizedDescription)
        }
    }
    
    private func showError(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        show(alertController, sender: nil)
    }
}
