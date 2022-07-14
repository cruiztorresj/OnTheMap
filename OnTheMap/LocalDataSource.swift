//
//  LocalDataSource.swift
//  OnTheMap
//
//  Created on 2/6/17.
//

class LocalDataSource {
    var students = [StudentInformation]()
    var loggedInStudentKey: String? = nil
    var loggedInStudentInformation = StudentInformation(firstName: nil, lastName: nil, location: nil, url: nil)
    
    static let sharedInstance = LocalDataSource()
    
    private init() {}
}
