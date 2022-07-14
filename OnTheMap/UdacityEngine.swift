//
//  UdacityEngine.swift
//  OnTheMap
//

import Foundation

class UdacityEngine {
    var SessionId: String? = nil
    
    func LoginToUdacity(username: String, password: String, completionHandlerForLogin: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        getSessionStudentKey(username, password) { (success, sessionStudentKey, errorString) in
            if success {
                LocalDataSource.sharedInstance.loggedInStudentKey = sessionStudentKey
            } else {
                completionHandlerForLogin(success, errorString)
            }
            
            completionHandlerForLogin(success, errorString)
        }
    }
    
    func LogoutFromUdacity(completionHandlerForLogout: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        GeneralEngine.sharedInstance.deleteUdacitySession() { (results, error) in
            if let error = error  {
                completionHandlerForLogout(false, error.localizedDescription)
            } else {
                completionHandlerForLogout(true, nil)
            }
        }
    }
    
    func getSingleStudentInformation(withStudentKey studentKey: String, completionHandlerForGetSingleStudentInfo: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        let method = "\(Constants.Udacity.UsersMethod)/\(studentKey)"
        
        let _ = GeneralEngine.sharedInstance.taskForGETMethod(method, parameters: parameters, host: Constants.Udacity.ApiHost, apiPath: Constants.Udacity.ApiPath) { (results, error) in
            if let error = error  {
                completionHandlerForGetSingleStudentInfo(false, error.localizedDescription)
            } else {
                if let student = results?[Constants.Udacity.JSONResponseKeys.user] as? [String : AnyObject] {
                    if let studentLastName = student[Constants.Udacity.JSONResponseKeys.lastName] as? String, let studentFirstName = student[Constants.Udacity.JSONResponseKeys.firstName] as? String {
                        LocalDataSource.sharedInstance.loggedInStudentInformation.lastName = studentLastName
                        LocalDataSource.sharedInstance.loggedInStudentInformation.firstName = studentFirstName
                    } else {
                        completionHandlerForGetSingleStudentInfo(false, "Couldn't find \"\(Constants.Udacity.JSONResponseKeys.lastName)\" and-or \"\(Constants.Udacity.JSONResponseKeys.firstName)\" key(s) in response")
                    }
                } else {
                    completionHandlerForGetSingleStudentInfo(false, "Couldn't find \"\(Constants.Udacity.JSONResponseKeys.user)\" key in response")
                }
                completionHandlerForGetSingleStudentInfo(true, nil)
            }
        }
        
    }
    
    private func getSessionStudentKey(_ username: String, _ password: String, _ completionHandlerForSession: @escaping (_ success: Bool, _ sessionStudentKey: String?, _ errorString: String?) -> Void){
        let parameters = [String:AnyObject]()
        let method = Constants.Udacity.SessionMethod
        let jsonBody = "{\"udacity\": {\"\(Constants.Udacity.JSONRequestKeys.username)\": \"\(username)\", \"\(Constants.Udacity.JSONRequestKeys.password)\": \"\(password)\"}}"
    
        let _ = GeneralEngine.sharedInstance.taskForPostMethod(method, parameters: parameters as [String:AnyObject], jsonBody: jsonBody, host: Constants.Udacity.ApiHost, apiPath: Constants.Udacity.ApiPath) { (results, error) in
            if let error = error  {
                if self.isInvalidCredentialsError(error.code) {
                    completionHandlerForSession(false, nil, Constants.Udacity.InvalidCredentialsMsg)
                } else {
                    completionHandlerForSession(false, nil, error.localizedDescription)
                }
            } else {
                if let account = results?[Constants.Udacity.JSONResponseKeys.account] as? [String : AnyObject] {
                    if let studentKey = account[Constants.Udacity.JSONResponseKeys.studentKey] as? String {
                        completionHandlerForSession(true, studentKey, nil)
                    } else {
                        completionHandlerForSession(false, nil, "Couldn't find \"\(Constants.Udacity.JSONResponseKeys.studentKey)\" key in results")
                    }
                } else {
                    completionHandlerForSession(false, nil, "Couldn't find \"\(Constants.Udacity.JSONResponseKeys.account)\" key in results")
                }
            }
        }
    }
    
    private func isInvalidCredentialsError(_ code: Int) -> Bool {
        return code == Constants.Udacity.InvalidCredentialsStatusCode
    }
    
    static let sharedInstance = UdacityEngine()
    
    private init() {}
}
