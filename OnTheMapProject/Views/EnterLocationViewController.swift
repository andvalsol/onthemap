//
//  EnterLocationViewController.swift
//  OnTheMapProject
//
//  Created by Andrey Valverde Solera on 3/9/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class EnterLocationViewController: UIViewController {
    
    @IBOutlet weak var enterLocationTextField: UITextField!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the loading indicator as hidden at first
        shouldShowLoadingIndicator(bool: false)
    }
    
    @IBAction func find(_ sender: Any) {
        // Get the location that the user typed
        // Check that the location is not nil
        guard let userLocation = enterLocationTextField.text else { return }
        
        // Show the loading indicator
        shouldShowLoadingIndicator(bool: true)
        
        // Search for the user location
        searchUserLocation(userLocation)
    }
    
    private func shouldShowLoadingIndicator(bool: Bool) {
        loadingIndicator.isHidden = !bool
    }
    
    private func searchUserLocation(_ location: String) {
        // Get the user location coordinates from the location text
        CLGeocoder().geocodeAddressString(location) { (placemark, error) in
            // Remove the loading indicator
            self.shouldShowLoadingIndicator(bool: false)
            
            guard let placemark = placemark else {
                // An error was found, show the user a proper error message
                self.showError(errorMessage: error!.localizedDescription)
                
                return
            }
            
            let coordinates = placemark.first!.location!.coordinate
            // Send the coordinates into the UserLocationViewController
            
            self.performSegue(withIdentifier: "sendPin", sender: (location, coordinates))
        }
    }
    
    private func showError(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        show(alertController, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendPin" {
            if let destinationViewController = segue.destination as? UserLocationViewController {
                let location = sender as! (String, CLLocationCoordinate2D)
                
                destinationViewController.locationName = location.0
                destinationViewController.coordinate = location.1
            }
        }
    }
}
