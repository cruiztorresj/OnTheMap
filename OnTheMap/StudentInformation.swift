//
//  StudentInformation.swift
//  OnTheMap
//
//  Created on 2/5/17.
//

import MapKit

struct StudentInformation {
    var firstName: String?
    var lastName: String?
    var name: String {
        return "\(firstName!) \(lastName!)"
    }
    
    var url: String?
    
    var location: CLLocationCoordinate2D?
    
    init(dict: [String: AnyObject]){
        self.firstName = dict[Constants.Parse.JSONResponseKeys.firstName] as! String?
        self.lastName = dict[Constants.Parse.JSONResponseKeys.lastName] as! String?
        self.url = dict[Constants.Parse.JSONResponseKeys.mediaURL] as! String?
        self.location = CLLocationCoordinate2D(latitude: dict[Constants.Parse.JSONResponseKeys.latitude] as! CLLocationDegrees, longitude: dict[Constants.Parse.JSONResponseKeys.longitude] as! CLLocationDegrees)
    }
    
    init(firstName: String?, lastName: String?, location: CLLocationCoordinate2D?, url: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.location = location
        self.url = url
    }
}
