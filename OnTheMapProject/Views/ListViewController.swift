//
//  ListViewController.swift
//  OnTheMapProject
//
//  Created by Andrey Valverde Solera on 3/6/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "On the Map"
        
        getStudents()
    }
    
    private func getStudents() {
        UdacityClient.getAllStudentLocationsWithLimit(limit: 100) { (results, error) in
            if let results = results {
                StudentModel.students = results
                
                self.tableView.reloadData()
                
            } else {
                // Show the user a proper error message
                self.showError(errorMessage: error!.localizedDescription)
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        UdacityClient.logout { (success, error) in
            if success {
                // Dismiss the present view controller
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
            } else {
                // Show the user a proper error message
                self.showError(errorMessage: error!.localizedDescription)
            }
        }
    }
    
    private func showError(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        show(alertController, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableViewCell")!
        
        let student = StudentModel.students[indexPath.row]
        
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.students.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentModel.students[indexPath.row]
        
        if let mediaURL = URL(string: student.mediaURL) {
            // Open the LinkedIn profile of the student
            UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
        }
    }
}
