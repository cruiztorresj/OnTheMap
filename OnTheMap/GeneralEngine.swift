//
//  GeneralEngine.swift
//  OnTheMap
//
//  Created on 1/29/17.
//

import Foundation

class GeneralEngine {
    var session = URLSession.shared
    
    func taskForGETMethod(_ method: String, parameters: [String:AnyObject], host: String, apiPath: String, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let isParseCall = host == Constants.Parse.ApiHost
        let isUdacityCall = host == Constants.Udacity.ApiHost
        
        // Build the URL
        let request = NSMutableURLRequest(url: URLFromParameters(parameters, host, apiPath, withPathExtension: method))
        request.httpMethod = Constants.HTTPMethodGet
        request.addValue(Constants.AppJSONType, forHTTPHeaderField: "Accept")
        request.addValue(Constants.AppJSONType, forHTTPHeaderField: "Content-Type")
        
        if isParseCall {
            request.addValue(Constants.Parse.ApplicationId, forHTTPHeaderField: Constants.Parse.HeaderApplicationId)
            request.addValue(Constants.Parse.RESTApiKey, forHTTPHeaderField: Constants.Parse.HeaderRESTApiKey)
        }
        
        // Make request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            func sendError(_ error: String, code: Int) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGetMethod", code: code, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError("\(error!.localizedDescription)", code: Constants.GenericErrorCode)
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(Constants.OtherStatusCodeErrorMsg, code: Constants.GenericErrorCode)
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError(Constants.RequestNoDataErrorMsg, code: Constants.GenericErrorCode)
                return
            }
            
            // Parse the data and use the data (happens in completion handler)
            if isUdacityCall {
                let range = Range(uncheckedBounds: (Constants.Udacity.CharsToSkipStart, data.count - Constants.Udacity.CharsToSkipEnd))
                let newData = data.subdata(in: range)
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
            } else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    public func taskForPostMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, host: String, apiPath: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let isUdacityCall = host == Constants.Udacity.ApiHost
        let isParseCall = host == Constants.Parse.ApiHost
        
        // Build the URL
        let request = NSMutableURLRequest(url: URLFromParameters(parameters, host, apiPath, withPathExtension: method))
        request.httpMethod = Constants.HTTPMethodPost
        request.addValue(Constants.AppJSONType, forHTTPHeaderField: "Accept")
        request.addValue(Constants.AppJSONType, forHTTPHeaderField: "Content-Type")
        
        if isParseCall {
            request.addValue(Constants.Parse.ApplicationId, forHTTPHeaderField: Constants.Parse.HeaderApplicationId)
            request.addValue(Constants.Parse.RESTApiKey, forHTTPHeaderField: Constants.Parse.HeaderRESTApiKey)
        }
        
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        // Make request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            func sendError(_ error: String, code: Int) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPostMethod", code: code, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError("\(error!.localizedDescription)", code: Constants.GenericErrorCode)
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                var errorCode: Int
                
                if isUdacityCall {
                    errorCode = ((response as? HTTPURLResponse)?.statusCode)!
                } else {
                    errorCode = Constants.GenericErrorCode
                }
                
                sendError(Constants.OtherStatusCodeErrorMsg, code: errorCode)
                
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError(Constants.RequestNoDataErrorMsg, code: Constants.GenericErrorCode)
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            
            if isUdacityCall {
                let range = Range(uncheckedBounds: (Constants.Udacity.CharsToSkipStart, data.count - Constants.Udacity.CharsToSkipEnd))
                let newData = data.subdata(in: range)
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
            } else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            }
        }
        
        task.resume()
        
        return task
    }
    
    public func deleteUdacitySession(completionHandlerForDeleteUdacitySession: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void){
        
        let request = NSMutableURLRequest(url: URLFromParameters([String:AnyObject](), Constants.Udacity.ApiHost, Constants.Udacity.ApiPath, withPathExtension: Constants.Udacity.SessionMethod))
        
        request.httpMethod = Constants.HTTPMethodDelete
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String, code: Int) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDeleteUdacitySession(nil, NSError(domain: "deleteUdacitySession", code: code, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("\(error!.localizedDescription)", code: Constants.GenericErrorCode)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(Constants.OtherStatusCodeErrorMsg, code: Constants.GenericErrorCode)
                return
            }
            
            guard let data = data else {
                sendError(Constants.RequestNoDataErrorMsg, code: Constants.GenericErrorCode)
                return
            }
            
            let range = Range(uncheckedBounds: (Constants.Udacity.CharsToSkipStart, data.count - Constants.Udacity.CharsToSkipEnd))
            let newData = data.subdata(in: range)
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDeleteUdacitySession)
        }
        
        task.resume()
    }
    
    private func URLFromParameters(_ parameters: [String : AnyObject], _ host: String, _ apiPath: String, withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        
        components.scheme = Constants.ApiScheme
        components.host = host
        components.path = apiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.url!
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    static let sharedInstance = GeneralEngine()
    
    private init() {}
}
