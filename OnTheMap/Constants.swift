//
//  Constants.swift
//  OnTheMap


struct Constants {
    // MARK: General - Core
    static let ApiScheme = "https"
    static let AppJSONType = "application/json"
    static let HTTPMethodPost = "POST"
    static let HTTPMethodGet = "GET"
    static let HTTPMethodDelete = "DELETE"
    static let EnterYourLinkMsg = "Enter your link here!"
    static let ErrorTitle = "An Error has ocurred"
    static let NoMatchingLocationErrorMsg = "No matching location was found."
    static let BothFieldsRequiredErrorMsg = "Both username and password fields are required to login."
    static let EmptyLocationErrorMsg = "Please provide your location ir order to continue."
    static let EmptyLinkErrorMsg = "Please provide your URL ir order to continue."
    static let OtherStatusCodeErrorMsg = "Your request returned a status code other than 2xx!"
    static let RequestNoDataErrorMsg = "No data was returned by the request!"
    static let RequestErrorMsg = "There was an error with your request:"
    static let GenericErrorCode = 1
    static let CellIdentifier = "studentInformationCell"
    static let PinImageString = "PinImage"
    static let OK = "OK"
    
    // MARK: Udacity API
    struct Udacity {
        static let ApiHost = "www.udacity.com"
        static let SignUpURL = "https://www.udacity.com/account/auth#!/signup"
        static let ApiPath = "/api"
        static let SessionMethod = "/session"
        static let UsersMethod = "/users"
        static let CharsToSkipStart = 5
        static let CharsToSkipEnd = 0
        static let InvalidCredentialsStatusCode = 403
        static let InvalidCredentialsMsg = "Account not found or invalid credentials."
        
        struct JSONRequestKeys {
            static let username = "username"
            static let password = "password"
        }
        
        struct JSONResponseKeys {
            static let studentKey = "key"
            static let session = "session"
            static let account = "account"
            static let id = "id"
            static let registered = "registered"
            static let user = "user"
            static let lastName = "last_name"
            static let firstName = "first_name"
        }
    }
    
    // MARK: Parse API
    struct Parse {
        static let ApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let HeaderApplicationId = "X-Parse-Application-Id"
        static let HeaderRESTApiKey = "X-Parse-REST-API-Key"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
        static let StudentsLocationMethod = "/StudentLocation"
        
        struct ParameterKeys {
            static let order = "order"
            static let limit = "limit"
        }
        
        struct JSONRequestKeys {
            static let uniqueKey = "uniqueKey"
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let mapString = "mapString"
            static let mediaURL = "mediaURL"
            static let latitude = "latitude"
            static let longitude = "longitude"
        }
        
        struct JSONResponseKeys {
            static let results = "results"
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let latitude = "latitude"
            static let longitude = "longitude"
            static let mediaURL = "mediaURL"
            static let createdAt = "createdAt"
        }
    }
}
