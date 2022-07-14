//
//  OnTheMapCommonExtension.swift
//  OnTheMap
//
//  Created on 2/8/17.
//

import UIKit

extension OnTheMapUtileries {
    func openURLInBrowser(_ hostViewController: UIViewController, withURL url: String) {
        guard let theURL =  URL(string: url) else {
            self.displayError(hostViewController, "Can't open url: \(url)")
            return
        }
        
        if UIApplication.shared.canOpenURL(theURL) {
            UIApplication.shared.open(theURL)
        } else {
            self.displayError(hostViewController, "Can't open url: \(url)")
        }
    }
    
    func displayError(_ hostViewController: UIViewController, _ errorString: String?) {
        if let errorString = errorString {
            let ac = UIAlertController(title: Constants.ErrorTitle, message: errorString, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: Constants.OK, style: .default))
            hostViewController.present(ac, animated: true)
        }
    }
}

extension OnTheMapCommon {
    func clearLocalDataSource() {
        LocalDataSource.sharedInstance.students.removeAll()
    }
    
    func endUdacitySession(_ hostViewController: UIViewController) {
        UdacityEngine.sharedInstance.LogoutFromUdacity() { (success, errorString) in
            performUIUpdatesOnMain {
                if !success {
                    self.displayError(hostViewController, errorString)
                }
                hostViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func refreshStudentData(_ hostViewController: UIViewController) {
        clearLocalDataSource()
        updateViewInformation()
        ParseEngine.sharedInstance.getStudentsLocations(){ (success, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.updateViewInformation()
                } else {
                    self.displayError(hostViewController, errorString)
                }
            }
        }
    }
    
    func initStudentsArray() {
        students = LocalDataSource.sharedInstance.students
    }
}
