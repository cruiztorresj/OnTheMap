//
//  ViewController.swift
//  OnTheMap

import UIKit
import MapKit

class LoginViewController: UIViewController, UITextFieldDelegate, OnTheMapUtileries {
    @IBOutlet private weak var username: UITextField!
    @IBOutlet private weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginActivityView: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction private func pressLogin(_ sender: UIButton) {
        if !(username.text?.isEmpty ?? true) && !(password.text?.isEmpty ?? true) {
            setUIButtonEnabled(false)
            loginActivityView.startAnimating()
            UdacityEngine.sharedInstance.LoginToUdacity(username: username.text!, password: password.text!) { (success, errorString) in
                performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayError(self, errorString)
                        self.setUIButtonEnabled(true)
                        self.loginActivityView.stopAnimating()
                    }
                }
            }
        } else {
            displayError(self, Constants.BothFieldsRequiredErrorMsg)
        }
    }
    
    @IBAction func pressSignUp(_ sender: UIButton) {
        openURLInBrowser(self, withURL: Constants.Udacity.SignUpURL)
    }
    
    private func completeLogin() {
        UdacityEngine.sharedInstance.getSingleStudentInformation(withStudentKey: LocalDataSource.sharedInstance.loggedInStudentKey!) { (success, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.showTabbedView()
                } else {
                    self.displayError(self, errorString)
                    self.loginActivityView.stopAnimating()
                }
            }
        }
    }
        
    private func showTabbedView() {
        resetUIToInitialState()
        let controller = storyboard!.instantiateViewController(withIdentifier: "OnTheMapTabBarManager") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }
    
    private func setUIButtonEnabled(_ enabled: Bool) {
        loginButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    private func resetUIToInitialState() {
        username.text = ""
        password.text = ""
        setUIButtonEnabled(true)
        self.loginActivityView.stopAnimating()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let keybSize = getKeyboardHeight(notification)
        view.frame.origin.y = -keybSize
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
