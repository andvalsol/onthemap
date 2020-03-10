//
//  UdacityClient.swift
//  OnTheMapProject
//
//  Created by Andrey Valverde Solera on 3/6/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

import Foundation

class UdacityClient {
    
    struct Auth {
        static fileprivate (set) var accountKey: String?
        static fileprivate (set) var sessionID: String?
    }
    
    enum EndPoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case createSession
        case logout
        case getAllStudentLocations
        case getStudentLocationsWithLimit(limit: Int)
        case getUserInfo(userID: String)
        case postUserInfo
        
        private var stringValue: String {
            switch self {
            case .createSession, .logout: return "\(EndPoints.base)/session"
            case .getAllStudentLocations: return "\(EndPoints.base)/StudentLocation"
            case .getStudentLocationsWithLimit(let limit): return "\(EndPoints.base)/StudentLocation?limit=\(String(limit))&order=-updatedAt"
            case .getUserInfo(let userID): return "\(EndPoints.base)/users/\(userID)"
            case .postUserInfo: return "\(EndPoints.base)/StudentLocation"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getAllStudentLocationsWithLimit(limit: Int, completion: @escaping ([StudentLocation]?, Error?) -> Void) {
        
        print("The url is: \(EndPoints.getStudentLocationsWithLimit(limit: limit).url)")
        taskForGETRequest(url: EndPoints.getStudentLocationsWithLimit(limit: limit).url, responseType: StudentLocationResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        // Use DELETE method
        var request = URLRequest(url: EndPoints.logout.url)
        request.httpMethod = "DELETE"

        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared

        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie}
        }

        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            
            } else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func getAllStudentLocations(completion: @escaping ([StudentLocation]?, Error?) -> Void) {
        taskForGETRequest(url: EndPoints.getAllStudentLocations.url, responseType: StudentLocationResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func getUserData(completion: @escaping (UserReponse?, Error?) -> Void) {
        taskForGETRequest(url: EndPoints.getUserInfo(userID: Auth.accountKey!).url, responseType: UserReponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
                
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func postPin(user: PostUser, completion: @escaping (Bool, Error?) -> Void) {
        let headers = ["Content-Type" : "application/json"]
        
        taskForPOSTRequest(shouldSanitize: false, body: user, url: EndPoints.postUserInfo.url, values: headers, responseType: PostUserLocationResponse.self) { (response, error) in
            if response != nil {
                completion(true, nil)
            
            } else {
                completion(false, error)
            }
        }
    }
    
    class func createSession(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = SessionRequest(user: User(username: email, password: password))
        
        taskForPOSTRequest(shouldSanitize: true, body: body, url: EndPoints.createSession.url, values: ["Accept": "application/json", "Content-Type": "application/json"], responseType: PostSession.self) { (response, error) in
            if let response = response {
                Auth.sessionID = response.session.id
                Auth.accountKey = response.account.key
                
                completion(true, nil)

            } else {
                completion(false, error)
            }
        }
    }
    
    class func taskForGETRequest<T: Decodable>(url: URL, responseType: T.Type, completion: @escaping (T?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(T.self, from: data)
                
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
                
            } catch {
                do {
                    let errorResponse = try decoder.decode(UdacityErrorResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        
        task.resume()
        
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(shouldSanitize: Bool, body: RequestType, url: URL, values: [String: String], responseType: ResponseType.Type,completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        request.httpBody = try! JSONEncoder().encode(body)
        
        for value in values {
            request.addValue(value.value, forHTTPHeaderField: value.key)
        }
        
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                
                do {
                    let responseObject = shouldSanitize ? try jsonDecoder.decode(ResponseType.self, from: sanitizeData(data: data)) : try jsonDecoder.decode(ResponseType.self, from: data)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                
                } catch {
                    do {
                        let errorResponse = shouldSanitize ? try jsonDecoder.decode(UdacityErrorResponse.self, from: sanitizeData(data: data)) : try jsonDecoder.decode(UdacityErrorResponse.self, from: data)
                        
                        DispatchQueue.main.async {
                            completion(nil, errorResponse)
                        }
                        
                    } catch {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
            
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
        
        return task
    }
    
    class func sanitizeData(data: Data) -> Data{
        return data.subdata(in: 5..<data.count)
    }
}
