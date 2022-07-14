//
//  OnTheMapMapViewController.swift
//  OnTheMap
//
//  Created on 2/3/17.
//

import UIKit
import MapKit

class OnTheMapMapViewController: UIViewController, MKMapViewDelegate, OnTheMapCommon {
    @IBOutlet private weak var studentsMapView: MKMapView!
    var students: [StudentInformation]!
    private var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        studentsMapView.removeAnnotations(studentsMapView.annotations)
        refreshStudentData(self)
    }
  
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = studentsMapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
   
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let urlToOpen = view.annotation?.subtitle! {
                openURLInBrowser(self, withURL: urlToOpen)
            }
        }
    }
    
    @IBAction func userPressLogout(_ sender: UIBarButtonItem) {
        endUdacitySession(self)
    }
    
    @IBAction func userPressRefresh(_ sender: UIBarButtonItem) {
        studentsMapView.removeAnnotations(studentsMapView.annotations)
        refreshStudentData(self)
    }
    
    private func addStudentsAnnotationsToMap() {
        for student in students {
            let annotation = MKPointAnnotation()
            annotation.title = student.name
            annotation.subtitle = student.url
            annotation.coordinate = student.location!
            annotations.append(annotation)
        }
        studentsMapView.addAnnotations(annotations)
    }
    
    func updateViewInformation() {
        initStudentsArray()
        addStudentsAnnotationsToMap()
    }
}
