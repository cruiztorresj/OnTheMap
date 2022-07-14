//
//  OnTheMapCommon.swift
//  OnTheMap
//
//  Created on 2/8/17.
//

protocol OnTheMapUtileries {}

protocol OnTheMapCommon: class, OnTheMapUtileries {
    var students: [StudentInformation]! {get set}
    
    func updateViewInformation() -> Void
}
