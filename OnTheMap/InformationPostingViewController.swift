//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created on 2/11/17.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate, OnTheMapUtileries {
    
    @IBOutlet weak var geocodingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var labelWhere: UILabel!
    @IBOutlet weak var labelStudying: UILabel!
    @IBOutlet weak var labelToday: UILabel!
    @IBOutlet weak var btnFindOnTheMap: UIButton!
    @IBOutlet weak var FstSVHeader: UIStackView!
    @IBOutlet weak var FstSVContent: UIStackView!
    @IBOutlet weak var FstSVFooter: UIStackView!
    @IBOutlet weak var userLocation: UITextField!
    
    var userLinkTextField: UITextField!
    var studentLocationMapView: MKMapView!
    var submitBtn: UIButton!
    let geocoder = CLGeocoder()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userLinkTextField = UITextField()
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        geocodingActivityIndicatorView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction private func userPressCancelPostingInformation(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func userPressFindOnTheMap(_ sender: UIButton) {
        if !(userLocation.text?.isEmpty ?? true) {
            geocodingActivityIndicatorView.isHidden = false
            
            // Geocode string
            geocoder.geocodeAddressString(userLocation.text!) { (placemarks, error) in
                self.processGeocoderResponse(withPlacemarks: placemarks, error: error)
            }
            
            geocodingActivityIndicatorView.startAnimating()
        } else {
            displayError(self, Constants.EmptyLocationErrorMsg)
        }
    }
    
    private func processGeocoderResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        geocodingActivityIndicatorView.stopAnimating()
        
        if let error = error {
            displayError(self, error.localizedDescription)
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                LocalDataSource.sharedInstance.loggedInStudentInformation.location = coordinate
                hideElementsFromFirstLayout()
                showSecondLayoutViewToUser()
            } else {
                displayError(self, Constants.NoMatchingLocationErrorMsg)
            }
        }
    }
    
    private func hideFstSVLabels(hidden: Bool) {
        labelWhere.isHidden = hidden
        labelStudying.isHidden = hidden
        labelToday.isHidden = hidden
    }
    
    private func setUpUserLinkTextField (){
        userLinkTextField.placeholder = Constants.EnterYourLinkMsg
        userLinkTextField.delegate = self
        FstSVHeader.addArrangedSubview(userLinkTextField)
    }
    
    private func setUpSubmitButton() {
        submitBtn = UIButton()
        submitBtn.setTitle("Submit", for: .normal)
        submitBtn.setTitleColor(UIColor.blue, for: .normal)
        submitBtn.translatesAutoresizingMaskIntoConstraints = false
        submitBtn.addTarget(self, action: #selector(self.submitStudentInformation), for: .touchUpInside)
        FstSVFooter.addArrangedSubview(submitBtn)
    }
    
    private func setUpStudentLocationMapView() {
        studentLocationMapView = MKMapView()
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: LocalDataSource.sharedInstance.loggedInStudentInformation.location!, span: span)
        studentLocationMapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = LocalDataSource.sharedInstance.loggedInStudentInformation.location!
        annotation.title = LocalDataSource.sharedInstance.loggedInStudentInformation.name
        annotation.subtitle = LocalDataSource.sharedInstance.loggedInStudentInformation.url
        studentLocationMapView.addAnnotation(annotation)
        
        FstSVContent.addArrangedSubview(studentLocationMapView)
    }
    
    private func showSecondLayoutViewToUser() {
        setUpUserLinkTextField()
        setUpStudentLocationMapView()
        setUpSubmitButton()
    }
    
    private func hideElementsFromFirstLayout() {
        hideFstSVLabels(hidden: true)
        geocodingActivityIndicatorView.isHidden = true
        userLocation.isHidden = true
        btnFindOnTheMap.isHidden = true
    }
    
    func submitStudentInformation() {
        if !(userLinkTextField.text?.isEmpty ?? true) {
            submitBtn.isEnabled = false
            geocodingActivityIndicatorView.startAnimating()
            LocalDataSource.sharedInstance.loggedInStudentInformation.url = userLinkTextField.text!
            ParseEngine.sharedInstance.postStudentInformation(withMapString: userLocation.text!) { (success, errorString) in
                performUIUpdatesOnMain {
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.displayError(self, errorString)
                        self.geocodingActivityIndicatorView.stopAnimating()
                        self.submitBtn.isEnabled = true
                    }
                }
            }
        } else {
            displayError(self, Constants.EmptyLinkErrorMsg)
        }
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
        if !userLinkTextField.isFirstResponder {
            let keybSize = getKeyboardHeight(notification)
            view.frame.origin.y = -keybSize
        }
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
