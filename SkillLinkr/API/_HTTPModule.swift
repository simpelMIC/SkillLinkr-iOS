//
//  HTTPModule.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import Foundation
import Security

struct ErrorResponse: Codable, Error {
    var status: String
    var message: String
}

class HTTPManager {
    struct LoginResponse: Codable {
        var status: String
        var message: Message
        
        struct Message: Codable {
            var token: String
        }
    }
    
    struct RegisterResponse: Codable {
        var status: String
        var message: Message
        
        struct Message: Codable {
            var token: String
        }
    }
    
    struct PatchResponse: Codable {
        var status: String
        var message: String
    }
    
    struct UserResponse: Codable, Equatable {
        var status: String
        var message: User
    }
    
    func login(mail: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        print("Logging in \(mail)...")
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/login") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "mail": mail,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    completion(.success(loginResponse))
                } catch let decodeError {
                    completion(.failure(decodeError))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    completion(.failure(decodeError))
                }
            } else {
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func register(mail: String, firstname: String, lastname: String, password: String, passwordConfirm: String, completion: @escaping (Result<RegisterResponse, Error>) -> Void) {
        print("Registering \(mail)...")
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/register") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "mail": mail,
            "firstname": firstname,
            "lastname": lastname,
            "password": password,
            "passwordConfirm": passwordConfirm
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            print("Error Code: 100-0")
            print(error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                print("Error Code: 100-1")
                print(error)
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                print("Error Code: 100-2")
                print(error)
                return
            }
            
            if httpResponse.statusCode == 201 {
                do {
                    let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                    completion(.success(registerResponse))
                } catch let decodeError {
                    completion(.failure(decodeError))
                    print("Error Code: 100-3")
                    print(decodeError)
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                    print("Error Code: 100-4")
                    print(error)
                } catch let decodeError {
                    completion(.failure(decodeError))
                    print("Error Code: 100-5")
                    print(decodeError)
                }
            } else {
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code"])
                completion(.failure(error))
                print("Error Code: 100-6")
                print(error)
            }
        }
        
        task.resume()
    }
    
    func getLoggedInUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/user") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        guard let token = SecureDataManager().loadToken() else {
            let errorResponse = ErrorResponse(status: "Invalid token", message: "Invalid token")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                    completion(.success(userResponse.message))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decorodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decorodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get users. Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func getUser(id: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/user/other/\(id)") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        guard let token = SecureDataManager().loadToken() else {
            let errorResponse = ErrorResponse(status: "Invalid token", message: "Invalid token")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                    completion(.success(userResponse.message))
                    print(userResponse)
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decorodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decorodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get users. Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func patchUser(patchUserId: String, firstname: String? = nil, lastname: String? = nil, password: String? = nil, roleID: Int? = nil, released: Bool? = nil, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        
        guard let url = URL(string: "\(DataManager().load(forKey: "apiURL") ?? defaultAPIURL)/user") else {
            let errorResponse = ErrorResponse(status: "Invalid API URL", message: "Invalid API URL")
            completion(.failure(errorResponse))
            return
        }
        
        guard let token = SecureDataManager().loadToken() else {
            let errorResponse = ErrorResponse(status: "Invalid token", message: "Invalid token")
            completion(.failure(errorResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        var parameters: [String: Any] = [
            "patchUserId": patchUserId
        ]
        
        if let firstname = firstname {
            parameters["firstname"] = firstname
        }
        
        if let lastname = lastname {
            parameters["lastname"] = lastname
        }
        
        if let password = password {
            parameters["password"] = password
        }
        
        if let roleID = roleID {
            parameters["roleID"] = roleID
        }
        
        if let released = released {
            parameters["released"] = released
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let response = try JSONDecoder().decode(PatchResponse.self, from: data)
                    completion(.success(response))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode error response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code: \(httpResponse.statusCode). Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
