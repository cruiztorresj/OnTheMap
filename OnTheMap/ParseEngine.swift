//
//  ParseEngine.swift
//  OnTheMap
//
//  Created on 2/6/17.
//

import Foundation

class ParseEngine {
    
    // Get students locations from parse API.
    func getStudentsLocations(_ completionHandlerForGetStudentsInformation: @escaping (_ success: Bool, _ errorString: String?) -> Void){
        
        // This time we will always retrieve data in descending order.
        let parameters: [String : AnyObject] = [Constants.Parse.ParameterKeys.limit: 100 as AnyObject, Constants.Parse.ParameterKeys.order : "-updatedAt" as AnyObject]
        let method = Constants.Parse.StudentsLocationMethod
        
        let _ = GeneralEngine.sharedInstance.taskForGETMethod(method, parameters: parameters, host: Constants.Parse.ApiHost, apiPath: Constants.Parse.ApiPath) { (results, error) in
            if let error = error  {
                completionHandlerForGetStudentsInformation(false, error.localizedDescription)
            } else {
                if let studentLocations = results?[Constants.Parse.JSONResponseKeys.results] as? [[String : AnyObject]] {
                    for studentLocation in studentLocations {
                        if let _ = studentLocation[Constants.Parse.JSONResponseKeys.firstName], let _ = studentLocation[Constants.Parse.JSONResponseKeys.lastName], let _ = studentLocation[Constants.Parse.JSONResponseKeys.mediaURL], let _ = studentLocation[Constants.Parse.JSONResponseKeys.latitude], let _ = studentLocation[Constants.Parse.JSONResponseKeys.longitude] {
                            LocalDataSource.sharedInstance.students.append(StudentInformation(dict: studentLocation))
                        } else {
                            continue
                        }
                        
                    }
                } else {
                    completionHandlerForGetStudentsInformation(false, "Couldn't find \"\(Constants.Parse.JSONResponseKeys.results)\" key in response")
                }
                completionHandlerForGetStudentsInformation(true, nil)
            }
        }
    }
    
    // Post single student information to parse
    func postStudentInformation(withMapString mapString: String, _ completionHandlerForPostStudentInformation: @escaping(_ success: Bool, _ errorString: String?) -> Void) {
        let parameters = [String:AnyObject]()
        let method = Constants.Parse.StudentsLocationMethod
        
        let uniqueKey = LocalDataSource.sharedInstance.loggedInStudentKey!
        let first = LocalDataSource.sharedInstance.loggedInStudentInformation.firstName!
        let last = LocalDataSource.sharedInstance.loggedInStudentInformation.lastName!
        let mediaURL = LocalDataSource.sharedInstance.loggedInStudentInformation.url!
        let latitude = LocalDataSource.sharedInstance.loggedInStudentInformation.location!.latitude
        let longitude = LocalDataSource.sharedInstance.loggedInStudentInformation.location!.longitude
        
        let jsonBody = "{\"\(Constants.Parse.JSONRequestKeys.uniqueKey)\": \"\(uniqueKey)\", \"\(Constants.Parse.JSONRequestKeys.firstName)\": \"\(first)\", \"\(Constants.Parse.JSONRequestKeys.lastName)\": \"\(last)\",\"\(Constants.Parse.JSONRequestKeys.mapString)\": \"\(mapString)\", \"\(Constants.Parse.JSONRequestKeys.mediaURL)\": \"\(mediaURL)\",\"\(Constants.Parse.JSONRequestKeys.latitude)\": \(latitude), \"\(Constants.Parse.JSONRequestKeys.longitude)\": \(longitude)}"
        
        let _ = GeneralEngine.sharedInstance.taskForPostMethod(method, parameters: parameters as [String:AnyObject], jsonBody: jsonBody, host: Constants.Parse.ApiHost, apiPath: Constants.Parse.ApiPath) { (results, error) in
            if let error = error  {
                completionHandlerForPostStudentInformation(false, error.localizedDescription)
            } else {
                if let responseData = results as? [String : AnyObject] {
                    if let _ = responseData[Constants.Parse.JSONResponseKeys.createdAt] as? String {
                        completionHandlerForPostStudentInformation(true, nil)
                    } else {
                        completionHandlerForPostStudentInformation(false, "Couldn't find \"\(Constants.Parse.JSONResponseKeys.createdAt)\" key in results")
                    }
                } else {
                    completionHandlerForPostStudentInformation(false, "Something went wrong while reading post results")
                }
            }
        }
        
    }
    
    static let sharedInstance = ParseEngine()
    
    private init () {}
}
